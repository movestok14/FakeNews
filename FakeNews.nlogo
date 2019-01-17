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

;; People move about at random.

to move  ;; turtle procedure
  rt random-float 360
  fd 1
end


to couple  ;; turtle procedure -- righties only!
  let potential-partner one-of (turtles-at -1 0)
                          with [not coupled? and shape = "person lefty"]
  if potential-partner != nobody
    [ if random-float 10.0 < [coupling-tendency] of potential-partner
      [ set partner potential-partner
        set coupled? true
        ask partner [ set coupled? true ]
        ask partner [ set partner myself ]
        move-to patch-here ;; move to center of patch
        ask potential-partner [move-to patch-here] ;; partner moves to center of patch
        set pcolor gray - 3
        ask (patch-at -1 0) [ set pcolor gray - 3 ] ] ]
end


to uncouple  ;; turtle procedure
  if coupled? and (shape = "person righty")
    [ if (couple-length > commitment) or
         ([couple-length] of partner) > ([commitment] of partner)
        [ set coupled? false
          set couple-length 0
          ask partner [ set couple-length 0 ]
          set pcolor black
          ask (patch-at -1 0) [ set pcolor black ]
          ask partner [ set partner nobody ]
          ask partner [ set coupled? false ]
          set partner nobody ] ]
end


to infect  ;; turtle procedure          ;;
  if coupled? and fakenews? and not known?      ;;,
    [ if random-float 10 > suspicion or random-float 10 > ([suspicion] of partner) ;;
        [ ifelse random-float 100 < infection-chance  
            [ ask partner [ set fakenews? true ] ] ;; fakenews
            [ ask partner [ set fakenews? false ] ] ;; truenews


  ] ]
end

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
