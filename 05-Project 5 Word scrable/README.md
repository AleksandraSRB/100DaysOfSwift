# Word scramble - Project 5 0f #100DaysOfSwift

## Description:
In this project we created a word game that deals with anagrams.

## Key points:
UIAlertController, UITextChecker, Closures, Capture lists, NSRange

## Challanges:
From Hacking with Swift:

1. Disallow answers that are shorter than three letters or are just our start word. For the three-letter check, the easiest thing to do is put a check into isReal() that returns false if the word length is under three letters. For the second part, just compare the start word against their input word and return false if they are the same.
2. Refactor all the else statements we just added so that they call a new method called showErrorMessage(). This should accept an error message and a title, and do all the UIAlertController work from there.
3. Add a left bar button item that calls startGame(), so users can restart with a new word whenever they want to.


## Screenshots:

<img width="349" alt="1" src="https://github.com/AleksandraSRB/100DaysOfSwift/assets/94380380/fe6edfc1-6f40-4cf8-9e7c-c6dd27970607">

<img width="346" alt="2" src="https://github.com/AleksandraSRB/100DaysOfSwift/assets/94380380/82806720-8d2e-4416-961f-d085b8cf7dce">

<img width="353" alt="3" src="https://github.com/AleksandraSRB/100DaysOfSwift/assets/94380380/9e9a0f59-6d59-4bcb-a0bc-3d462502a282">

<img width="345" alt="4" src="https://github.com/AleksandraSRB/100DaysOfSwift/assets/94380380/e493f275-a411-457f-b015-c6dd2a1e408e">

<img width="341" alt="5" src="https://github.com/AleksandraSRB/100DaysOfSwift/assets/94380380/70bc2981-da74-40a0-b6a7-87b2d2c9b861">
