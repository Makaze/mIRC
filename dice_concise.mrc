; dice_concise / Based on Marcel Kossin's 'dice' RP Dice Simulator for Irssi 
;
; What is this?
;
; -- Marcel Kossin's notes: --
;
; I (mkossin) often Dungeon Master on our Neverwinternights Servers called 'Bund der
; alten Reiche' (eng. 'Alliance of the old realms') at bundderaltenreiche.de
; (German Site) Often idling in our Channel I thought it might be Fun to have 
; a script to dice. Since I found nothing for irssi I wrote this little piece
; of script. The script assumes, that if a 'd' for english dice is given it 
; should print the output in English. On the other hand if a 'w' for German 
; 'Würfel' is given it prints the output in German. 
;
; Usage.
;
; Anyone on the Channel kann ask '!roll' to toss the dice for him. He just has
; to say what dice he want to use. The notation should be well known from
; RP :-) Thus
;
; Write: !roll <quantity of dice>d[or w for german users]<sides on dice>
;
; Here are some examples
;
; !roll 2d20
; !roll 3d6
;
; OK, I think you got it already :-)
;
; Write: !roll version 
; For Version Information
;
; Write: !roll help
; For Information about how to use it
;
; -- Makaze's notes: --
;
; [Changes in dice_concise:]
;
; Features added:
;
; [ ] Can add bonuses to the roll. e.g. "!roll 3d6+10"
; [ ] Output changed to one line only. e.g. "Makaze rolls the 3d6 and gets: 9 [4,
;     4, 1]"
; [ ] Corrected English grammar.
; [ ] Removed insults.
; [ ] Cleaner code with fewer nested if statements and true case switches.
; [ ] Errors call before the loop, saving clock cycles.
;
; Bugs fixed:
;
; [ ] Rolls within the correct range.*
;
; Edge cases added:
;
; [ ] Catch if rolling less than 1 dice.
; [ ] Catch if dice or sides are above 100 instead of 99.
;
; -----------------------------------------
;
; * [The original dice.pl rolled a number between 1 and (<number of sides> - 1)]
;   [instead of using the msg range. e.g. "!roll 1d6" would output 1 through   ]
;   [5, but never 6.                                                           ]
;
; -----------------------------------------
;
; Original script 'dice.pl' by mkossin.
;
; Ported and updated script 'dice_concise.mrc' by Makaze.
;
; Special thanks to SmartRutter for help with debugging.
;
; Licensed under GNU GPL v2 or later.

on $*:Text:/^!roll/i:#:{
    if ($2 == $null) {
        msg $chan "!roll help" - gives the English help
        msg $chan "!roll hilfe" - zeigt die deutsche Hilfe an
        halt
    }

    var %VERSION = 0.1.0
    var %msg = $$2

    if ($regex(roll, %msg, /(\d+)([dw])(\d+)/i)) {
        var %forloop = 0
        var %lang
        var %case
        var %dice = $regml(roll, 1)
        var %sides = $regml(roll, 3)
        var %main
        var %value = 0
        var %plus

        if ($regml(roll, 2) == w) {
            %lang = DE
        }
        else {
            %lang = EN
        }

        if ($regex(%msg, /\+/i)) {
            if ($regex(bonus, %msg, /\+(\d+)/i)) {
                %plus = $regml(bonus, 1)
                inc %value %plus
            }
            else {
                var %error.add = 1
            }
            %main = $gettok(%msg, 1, 43)
        }
        else {
            %main = %msg
        }

        if (%dice < 1) {
            if (%lang == DE) {
                msg $chan $nick macht nichts... Würfeln funktioniert am besten mit Würfeln.
            }
            else {
                msg $chan $nick does nothing... Rolling dice works best with dice.
            }
            halt
        }
        elseif (%dice > 100) {
            if (%lang == DE) {
                msg $chan $nick scheitert den %msg zu werfen... Versuch es mit weniger Würfeln.
            }
            else {
                msg $chan $nick fails to roll the %msg $+ ... Try fewer dice.
            }
            halt
        } 
        elseif (%sides <= 1) {
            if (%sides == 0) {
                if (%lang == DE) {
                    msg $chan $nick verursacht ein Paradox... Oder hat jemand schon mal einen Würfel ohne Seiten gesehen?
                }
                else {
                    msg $chan $nick causes a paradox... Or has anybody ever seen a die without sides?
                }
                halt
            }
            elseif (%sides == 1) {
                if (%lang == DE) {
                    msg $chan $nick verursacht ein Paradox... Oder hat jemand schon mal einen Würfel mit nur einer Seite gesehen?
                }
                else {
                    msg $chan $nick causes a paradox... Or has anybody ever seen a die with only one side?
                }
                halt
            }
        }
        elseif (%sides > 100) {
            if (%lang == DE) {
                msg $chan $nick scheitert den %msg zu werfen... Versuch es mit weniger Augen.
            }
            else {
                msg $chan $nick fails to roll the %msg $+ ... Try fewer sides.
            }
            halt
        }

        var %rolls

        while (%forloop < %dice) {
            var %rnd = $rand(1, %sides)
            inc %value %rnd
            if (%forloop == 0) {
                %rolls = %rnd
            }
            else {
                %rolls = %rolls $+ , %rnd
            }
            inc %forloop
        }

        %rolls = [ $+ %rolls
        %rolls = %rolls $+ ]

        if (%lang == DE) {
            msg $chan $nick würfelt mit dem %msg und erhält: %value %rolls
        }
        else {
            msg $chan $nick rolls the %msg and gets: %value %rolls
        }

        if (%error.add) {
            if (%lang == DE) {
                msg $chan $nick scheitert mehr zum Ergebnis hinzuzufügen. Versuch Zahlen zu addieren.
            }
            else {
                msg $chan $nick fails to add to their result. Try adding numbers.
            }
        }
        halt
    }
    elseif (%msg == version) {
        msg $chan dice_concise version %VERSION by Makaze
        halt
    }
    elseif (%msg == help) {
        msg $chan Syntax: "!roll <quantity of dice>d<sides on dice>" - e.g. "!roll 2d20"
        halt
    }
    elseif (%msg == hilfe) {
        msg $chan Syntax: "!roll <Anzahl der Würfel>w<Augen des Würfels>" - z.B. "!roll 2w20"
        halt
    }
    else {
        msg $chan "!roll help" - gives the English help
        msg $chan "!roll hilfe" - zeigt die deutsche Hilfe an
        halt
    }
}
