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

;;------------------------------
to recolor-grass
  ifelse spin = 1
  [set pcolor scale-color lime grass-amount 0 20]
  [set pcolor scale-color orange grass-amount 0 20]
end

  ;;set pcolor scale-color green grass-amount 0 20
;;end;;|
;; regrow the grass
to regrow-grass   ;;항상 방송에서 가짜뉴스를 틀어주는게 아니기 때문에 10%비율로 증가하게 함
  ask patches [
    set grass-amount grass-amount + grass-regrowth-rate
    if grass-amount > 10 [
      set grass-amount 10
    ]
    recolor-grass
  ]
end;;|
to eat
  ;; check to make sure there is grass here
  if ( grass-amount >= 0.1 ) [  ;;초록색 먹으면 1추가가됨, 원래코드는 energy-gain-from-grass였고 슬라이드로 조절가능
    ;; increment the sheep's energy
    set suspicion suspicion + 0.1
    ;; decrement the grass
    set grass-amount grass-amount - 5
    recolor-grass
  ]
end;;|



;; Each tick a check is made to see if sliders have been changed.
;; If one has been, the corresponding turtle variable is adjusted

to check-sliders

  if (slider-check-2 != active_tendency)
    [ ask turtles [ assign-coupling-tendency ]
      set slider-check-2 active_tendency ]
  if (slider-check-3 != Degree-of-suspicion)
    [ ask turtles [ assign-suspicion ]
      set slider-check-3 Degree-of-suspicion ]
  if (slider-check-4 != Worrying-time )
    [ ask turtles [ assign-test-frequency ]
      set slider-check-4 Worrying-time ]
end

;; People move about at random.

to move  ;; turtle procedure
  rt random-float 360
  fd 1
end

;; People have a chance to relationship depending on their tendency to have  and
;; if they meet.  To better show that coupling has occurred, the patches below
;; the relationship turn gray.

to relationship  ;; turtle procedure -- righties only!
  let potential-partner one-of (turtles-at -1 0)
                          with [not relationshipd? and shape = "person lefty"]
  if potential-partner != nobody
    [ if random-float 10.0 < [coupling-tendency] of potential-partner
      [ set partner potential-partner
        set relationshipd? true
        ask partner [ set relationshipd? true ]
        ask partner [ set partner myself ]
        move-to patch-here ;; move to center of patch
        ask potential-partner [move-to patch-here] ;; partner moves to center of patch
        set pcolor gray - 3
        ask (patch-at -1 0) [ set pcolor gray - 3 ] ] ]
end

;; If two peoples are together for longer than either person's commitment variable
;; allows, the relationship breaks up.

to unrelationship  ;; turtle procedure
  if relationshipd? and (shape = "person righty")
    [ if (relationship-length > commitment) or
         ([relationship-length] of partner) > ([commitment] of partner)
        [ set relationshipd? false
          set relationship-length 0
          ask partner [ set relationship-length 0 ]
          set pcolor black
          ask (patch-at -1 0) [ set pcolor black ]
          ask partner [ set partner nobody ]
          ask partner [ set relationshipd? false ]
          set partner nobody ] ]
end

;; Infection can occur if either person is fakenews, but the infection is unknown.
;; This model assumes that people with known infections will continue to relationship,
;; but will automatically practice safe , regardless of their suspicion tendency.
;; Note also that for condom use to occur, both people must want to use one.  If
;; either person chooses not to use a condom, infection is possible.  Changing the
;; primitive to AND in the third line will make it such that if either person
;; wants to use a condom, infection will not occur.

to infect  ;; turtle procedure          ;;★spread★
  if relationshipd? and fakenews? and not known?      ;;relationship이고,
    [ if random-float 10 > suspicion or random-float 10 > ([suspicion] of partner) ;;본인 혹은 파트너의 suspicion이 10보다 작으면 다음 if.
        [ ifelse random-float 100 < infection-chance   ;;100까지 랜덤값에서 50보다 작으면 fakenews
            [ ask partner [ set fakenews? true ] ] ;; fakenews로
            [ ask partner [ set fakenews? false ] ] ;; truenews로


  ] ]
end

;; People have a tendency to check out their health status based on a slider value.
;; This tendency is checked against a random number in this procedure. However, after being fakenews for
;; some amount of time called SYMPTOMS-SHOW, there is a 5% chance that the person will
;; become ill and go to a doctor and be tested even without the tendency to check.

to test  ;; turtle procedure
  if random-float 52 < test-frequency
    [ if fakenews?
        [ set known? true ] ]
  if infection-length > symptoms-show
    [ if random-float 100 < 5
        [ set known? true ] ]
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
