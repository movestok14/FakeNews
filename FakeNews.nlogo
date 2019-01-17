patches-own [ grass-amount ]  ;; patches have grass|

globals [
  infection-chance  ;; The chance out of 100 that an fakenews person will pass on
                    ;;   infection during one week of couplehood.
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
  coupled?           
  couple-length      
  ;; the next four values are controlled by sliders
  commitment         ;; 
  coupling-tendency  
  suspicion         
  test-frequency     
  partner            
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
    set pcolor scale-color green grass-amount 0 20

  ];;|

  setup-globals
  setup-people
  reset-ticks

end

to setup-globals
  set infection-chance 50    
                             
  set symptoms-show 200.0   

  set slider-check-2 active_tendency
  set slider-check-3 Degree-of-suspicion
  set slider-check-4 Worrying-time
end

to setup-people
  create-turtles initial-people
    [ setxy random-xcor random-ycor
      set known? false
      set coupled? false
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

to-report random-near [center]  ;;
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
      if coupled?
        [ set couple-length couple-length + 1 ] ]
  ask turtles
    [ if not coupled?
        [ move ] ]
  ask turtles
    [ if not coupled? and shape = "person righty" and (random-float 10.0 < coupling-tendency)
        [ couple ] ]
  ask turtles [ uncouple ]
  ask turtles [ infect ]
  ask turtles [ test ]
  ask turtles [ assign-color ]
  tick
end

;;------------------------------
to recolor-grass
  set pcolor scale-color green grass-amount 0 20
end;;|
;; regrow the grass
to regrow-grass
  ask patches [
    set grass-amount grass-amount + grass-regrowth-rate
    if grass-amount > 10 [
      set grass-amount 10
    ]
    recolor-grass
  ]
end;;|
