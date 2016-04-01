#Mobi-opoly

If you're reading this and you're not a (current or prospective) Mobi employee, one of us has done something terribly wrong. 
This document contains a writeup/specification for one high-level approach to architecting the game of Monopoly in Ruby.
Originally, I'd intended to record a whiteboard video of my design process. However, I spent a great deal of time 
passively thinking about the problem and with a large chunk of the design already mentally laid out, I feared such a 
 video wouldn't be as organic as I desired. Since I suspect the purpose of this exercise is to view the process just as 
 much as the final product, this document will read halfway like a blog post and halfway like formal documentation.
 
#### Conventions used in this doc

* Like the Ruby documentation, `Property#play` refers to the method called 'play' on class 'Property'
* Classes are initially referred to in bold, with their first letter capitalized, like so: **Property**. Subsequent 
references will only be capitalized.


## High-Level Overview
I wanted to design the game in such a way that modularity and expandability were highly prioritized. While it would have
been possible to write a version with many of the game's rules hard-coded, I wanted to try an approach that would allow
custom modifications or changes to accommodate the many, many versions of Monopoly in existence. 

We begin with a class called **GameState**. GameState loosely follows the 
[mediator pattern](https://en.wikipedia.org/wiki/Mediator_pattern). As we define the various other game components 
(players, properties, etc), GameState is the glue connecting all these classes. It alone initiates any action which 
 requires interaction between objects (for example, `Property#play` described later). In addition, it handles the 'global'
 state of the game, such as whose turn it is, rolling the dice and moving the players, who the banker is, upgrading 
 properties, etc.
 
A Monopoly board is made up of a series of spaces, and all those spaces something in common: Something happens
to the player that lands on them. Because of this, it makes sense that we define a set of expected behavior for all 
spaces in the game. Ruby doesn't have explicit abstract classes, but we can define a class to act as one. In this case,
we call it **Space.** Each Space has a method, `play(player, bank, players = nil, cards = nil)`, *which is only to ever
be called by the GameState*. This gives us transactional-like behavior if the game rules were to expand. 
These `Space#play` methods act upon the game components passed in, usually taking money from the player, giving it to the 
owner or bank, etc. 
  
The first and most common type of Space is a **Property**. The bulk of the Property behavior has already been defined in
the first part of this exercise, but has been refactored a bit for the new architecture. For example,  `Property#mortgage!` 
method now only affects the housing status of the Property itself. The associated financial transactions are handled by
GameState.

Of course, not all properties in the game of Monopoly act the same. Railroads and utility companies, in particular, act 
somewhat like Properties with their own special rules for players landing on them. For these, we use the creatively named
**SpecialProperty**. These are the first class which use `Proc`s to define custom behavior. The Proc passed into 
the SpecialProperty will simply be `instance_exec`ed inside `SpecialProperty#play`. Consider this example for the utility
spaces:
```
util = Proc.new do |player, bank|
      unless self.owner == player
        if (self.owner.properties.map(&:name).to_set) > ['Electric Company', 'Water Works'].to_set
          fee = 10 * ((1 + rand(6)) + 1 + rand(6))
          player.cash -= fee
          bank.cash += fee
        else
          fee = 4 * ((1 + rand(6)) + 1 + rand(6))
          player.cash -= fee
          bank.cash += fee
        end
      end
    end
    
    #...snip...

ww = SpecialProperty.new('Water Works', [0, 0, 0, 0, 0, 0], 0, 100, util)
```

**EventSpace**s are Spaces which cannot be owned but still cause an action to occur. Go To Jail, Community Chest, Chance,
Income Tax, and Luxury Tax are examples of such spaces. In the case of Community Chest and Chance, both of these accept 
 a `cards` argument to their initializers, where `cards` is simply an array of Procs affecting the Player, like so:
 
```
cards = [
    Proc.new do |player, bank|
        player.cash -= 100
        bank.cash += 100
    end
]
```

Finally, we have a **Player** class, which is fairly straightforward. The GameState maintains an array of Player objects
and passes them as arguments to `Space#Play` when a Player lands on that space.

### Omissions from the code

* A **Banker** class was left out for brevity. Because it has some similarity to Player (in that it has assets, and those
assets affect game rules/logic), I considered its implementation fairly trivial.
* Currently the only difficult to handle Space is "Go To Jail", since it moves the Player from one Space to another. There
are many potential solutions to this. Perhaps the most idiomatic with the current design is to extend the `EventSpace#Play`
to accept another Space as a parameter. Passing these in as an array of Spaces can also potentially simplify the design of
Spaces that interact with other Spaces on the board (namely Railroads and Utility companies, as above)


# Lessons Learned and Reflection

First of all, the most important lesson: **It's never as simple as it looks. It's. NEVER. As simple as it looks.

Overall I'm somewhat happy with the design, though there are some weaknesses. From a high level:

## Pros:
* Highly modular. Allows fairly sane and safe extension to the game rules, board, etc.
* Well organized. GameState's mediator pattern makes it easy to find the "brain" of the game logic, and move on from there.
* Well testable. 
* Highly configurable. The hard-coded cards in the GameState example could easily be replaced by calls to file reads. 
(It should be noted that these must be secured, as reading code from configurable source files is an attack vector for 
arbitrary code execution)

## Cons:
* Readability. Abundant use of concise Procs and some functional programming components means a consistent style is 
necessary.
* Breakability. Since the example was written to be modular, things can break in bad ways if the design intent is not 
followed by contributors. Therefore a good doc is key.
* One big engine. GameState is not necessarily poorly designed, but it is the 100-armed-robot setting all the other 
classes in motion. There are a lot of assumptions it makes, and those assumptions MUST be tested. Because of this, 
GameState's test coverage would be extensive, and I suspect test code would be roughly 3x GameState's SLOC

Feel free to contact me with any questions, comments, WTFs, and the like. I look forward to hearing from you!


