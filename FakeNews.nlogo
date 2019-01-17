patches-own [
  grass-amount
  spin   ;;holds -1 or 1

]  ;; patches have grass|




globals [
  infection-chance  ;; The chance out of 100 that an fakenews person will pass on
                    ;;   infection during one week of relationshiphood.
  symptoms-show     ;; How long a person will be fakenews before symptoms occur
                    ;;   which may cause the person to get tested.
  slider-check-1    ;; Temporary variables for slider values, so that if sliders
  slider-check-2    ;;   are changed on the fly, the model will notice and
  slider-check-3    ;;   change people's tendencies appropriately.
  slider-check-4
]

turtles-own [
  fakenews?          
  known?             
  infection-length   ;; How long the person has been fakenews.
  relationshipd?           
  relationship-length      ;; How long the person has been in a relationship.
  ;; the next four values are controlled by sliders
  commitment         ;; How long the person will stay in a relationship-relationship.
  coupling-tendency  ;; How likely the person is to join a relationship.
  suspicion         ;; The percent chance a person uses protection.
  test-frequency     ;; Number of times a person will get tested per year.
  partner            ;; The person that is our current partner in a relationship.
]

;;;
;;; SETUP PROCEDURES
;;;

to setup
  clear-all
  ;;---------------------------
    ask patches [
    ;; give grass to the patches, color it shades of green
    set grass-amount random-float 1.0

    ifelse random 100 < probability-of-spin-up
      [ set spin  1 ];; 진짜뉴스 색칠
      [ set spin -1 ];; 가짜뉴스 색칠
    recolor-grass
    ;;set pcolor scale-color green grass-amount 0 20
  ];;|

  setup-globals
  setup-people
  reset-ticks

end

to setup-globals
  set infection-chance 50    ;; if you have unprotected  with an fakenews partner,
                             ;; you have a 50% chance of being fakenews
  set symptoms-show 200.0    ;; symptoms show up 200 weeks after infection

  set slider-check-2 active_tendency
  set slider-check-3 Degree-of-suspicion
  set slider-check-4 Worrying-time
end

;; Create carrying-capacity number of people half are righty and half are lefty
;;   and some are sick.  Also assigns colors to people with the ASSIGN-COLORS routine.

to setup-people
  create-turtles initial-people
    [ setxy random-xcor random-ycor
      set known? false
      set relationshipd? false
      set partner nobody
      ifelse random 2 = 0
        [ set shape "person righty" ]
        [ set shape "person lefty" ]
      ;; 2.5% of the people start out fakenews, but they don't know it
      set fakenews? (who < initial-people * 0.025)
      if fakenews?
        [ set infection-length random-float symptoms-show ]
      assign-commitment
      assign-coupling-tendency
      assign-suspicion
      assign-test-frequency
      assign-color ]
end

;; Different people are displayed in 3 different colors depending on health
;; green is not fakenews
;; blue is fakenews but doesn't know it
;; red is fakenews and knows it

to assign-color  ;; turtle procedure
  ifelse not fakenews?
    [ set color green ]
    [ ifelse known?
      [ set color red ]
      [ set color blue ] ]
end

;; The following four procedures assign core turtle variables.  They use
;; the helper procedure RANDOM-NEAR so that the turtle variables have an
;; approximately "normal" distribution around the average values set by
;; the sliders.

to assign-commitment  ;; turtle procedure
  set commitment random-near 20
end

to assign-coupling-tendency  ;; turtle procedure
  set coupling-tendency random-near active_tendency
end

to assign-suspicion  ;; turtle procedure
  set suspicion random-near Degree-of-suspicion
end

to assign-test-frequency  ;; turtle procedure
  set test-frequency random-near Worrying-time
end

to-report random-near [center]  ;; 터틀 왔다갔다하는거 구현
  let result 0
  repeat 40
    [ set result (result + random-float center) ]
  report result / 20
end

;;;
;;; GO PROCEDURES
;;;

to go
  ;;----------------
  regrow-grass    ;; the grass grows back|

  if all? turtles [known?]
    [ stop ]
  check-sliders
  ask turtles
    [
     eat;;-----------------

      if fakenews?
        [ set infection-length infection-length + 1 ]
      if relationshipd?
        [ set relationship-length relationship-length + 1 ] ]
  ask turtles
    [ if not relationshipd?
        [ move ] ]
  ;; Righties are always the ones to initiate mating.  This is purely
  ;; arbitrary choice which makes the coding easier.
  ask turtles
    [ if not relationshipd? and shape = "person righty" and (random-float 10.0 < coupling-tendency)
        [ relationship ] ]
  ask turtles [ unrelationship ]
  ask turtles [ infect ]
  ask turtles [ test ]
  ask turtles [ assign-color ]
  tick
end



;;;
;;; MONITOR PROCEDURES
;;;

to-report %fakenews
  ifelse any? turtles
    [ report (count turtles with [fakenews?] / count turtles) * 100 ]
    [ report 0 ]
end
; Copyright 1997 Uri Wilensky.; See Info tab for full copyright and license.
