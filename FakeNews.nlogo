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
