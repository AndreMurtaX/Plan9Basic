' =============================================
' Plan9Basic - Guess the Number Game
' Classic number guessing game demo
' =============================================
PRINTLN "=========================================="
PRINTLN "       GUESS THE NUMBER GAME"
PRINTLN "=========================================="
PRINTLN
' Initialize random number generator
randomize()
secret = rnd(100) + 1
maxattempts = 7
PRINTLN "I'm thinking of a number between 1 and 100."
PRINTLN "You have "; maxattempts; " attempts to guess it."
PRINTLN
PRINTLN "(Demo mode: Using DATA statements for guesses)"
PRINTLN
' Simulated guesses using DATA/READ
DATA 50, 75, 62, 55, 58, 57, 56
FOR attempt = 1 TO maxattempts
  READ guess
  PRINTLN "Attempt "; attempt; ": You guess "; guess
  IF guess = secret THEN
    PRINTLN
    PRINTLN "*** CONGRATULATIONS! ***"
    PRINTLN "You found the number in "; attempt; " attempts!"
    GOTO endgame
  ENDIF
  IF guess < secret THEN
    PRINTLN "  -> Too low! Try higher."
  ELSE
    PRINTLN "  -> Too high! Try lower."
  ENDIF
  PRINTLN
NEXT
PRINTLN "Sorry! You ran out of attempts."
PRINTLN "The secret number was: "; secret
endgame:
PRINTLN
PRINTLN "=========================================="
PRINTLN "         GAME OVER"
PRINTLN "=========================================="
PRINTLN
' Show some random number statistics
PRINTLN "Random Number Demo:"
PRINTLN "5 random numbers (0.0 - 1.0):"
FOR i = 1 TO 5
  PRINTLN "  "; rnd()
NEXT
PRINTLN
PRINTLN "5 random integers (1 - 100):"
FOR i = 1 TO 5
  PRINTLN "  "; rnd(100) + 1
NEXT
PRINTLN
PRINTLN "5 random integers (1 - 6) - Dice roll:"
FOR i = 1 TO 5
  PRINTLN "  "; rnd(6) + 1
NEXT
