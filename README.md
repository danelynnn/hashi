# hashi

it's hashi (/hæʃi/)

## about

on the fateful day of (around) March 5, 2024, my friend introduced me to the wonderful little game known as Hashi(wokakero). it's a lovely little puzzle game where there are islands, with a number on them, and bridges! the number says how many bridges it needs to be connected to it, and... yeah [here](https://www.puzzle-bridges.com/), just play it, it'll help a lot more than this explanation

for some reason, though, my first instinct while playing this game as a wee novice wasn't "wow that's cool I should learn this over time"; it was, instead: "damn y'know I wish the game would actually tell me how many bridges were "left to build" on an island, not the original number, who needs that". this sparked an incredible argument where my kind, patient friend, suggested that "that would probably trivialise the game". I disagreed, and after a couple back and forths, I had a pretty bonkers idea:

what if I just remade the entire game from scratch, but implemented this "feature"?

## about, pt 2

I started work on this soon after this conversation, figuring that this would only be a 1 week adventure at most, in and out. after all, all I intended was to implement the game's mechanics from scratch, and maybe procedurally generate the levels from [some algorithm I found online](https://arxiv.org/pdf/1905.00973). little did I know that it might actually be pretty hard to procedurally generate Hashi levels that were not only customisable, but also fun. this algorithm kinda... didn't... work?

but, I didn't know this at the time, so I got work on starting the algorithm basically as soon as I got a grid set up. and, after the planned week, I found myself no closer to a full Hashi game than I did on the first day.

so i quit.

## about, pt 3

fast forward to like, 6/7/2026, when I, out of the blue, decided to brush the dirt off of this two-year-old project. with the benefit of hindsight, I realised that maybe reinventing the entire level generation algorithm seemed a bit foolish, but also, kinda dull? so, I decided to put it aside, and actually first just make the game, using hardcoded levels just copied manually from the website.

as fortune may have it, when I eventually did have to circle back to the "level gen" obstacle, I actually realised there was a much better option than reinventing the level gen algorithm (foreshadowing)

and about a week and a half later, after about a couple days of work, I now present, the most over(under??)engineered implementation of Hashi, the hit puzzle game :D

## technical details

- main code is written in Processing 3 (Java), my guilty pleasure
- backend code is written in Python with Flask for API support
- level. generation.
  - rather than recreating level generation, levels are loaded directly from the website through Selenium
  - pixel values of islands are recorded and stored into a numpy array, then processed into coordinates

## TODO

- confetti

## compiling into a .exe

this application is made in Processing 3.5.4, so compiling it will require using the Processing application (found at https://processing.org/releases). IMPORTANT: Processing 3 must be used, as 4 is a broken mess that never should have been released

1. open the project in Processing  
   ![step1](img/step1.png)

2. find the Export Application menu option  
   ![step2](img/step2.png)

3. set options for desired platform  
   ![step3](img/step3.png)

4. compiled .exe's can be found in the hashi/ folder:  
   ![step4](img/step4.png) ![step4](img/step4.5.png)
