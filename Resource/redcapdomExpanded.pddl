;Header and description
(define (domain redcap_dom_ex)
;remove requirements that are not needed
(:requirements :typing :conditional-effects :negative-preconditions :strips :disjunctive-preconditions :equality :action-costs :universal-preconditions)
(:types ;todo: enumerate types and their hierarchy here, e.g. car truck bus - vehicle
    character item location hazzard trap - omni
    gift consumable weapon - item
    blade - weapon
    monster - character
)
; un-comment following line if constants are needed
(:predicates ;todo: define predicates here
    (inventory ?item - item ?char - character)
    (whereabouts ?loc - location ?char - character)
    (hate ?char1 - character ?char2 - character)
    (inside ?vict - character ?mon - monster)
    (oblivious ?o - location ?char - character)
    (atloc ?o - omni ?loc - location)
    (isdead ?char - character)
    (isasleep ?char - character)
    (issick ?char - character)
    (cangobble ?mon - character)
    (imobile ?char - character)
    (issaved ?vict - character)
    (isset ?trap - trap)
    (isweakened ?mon - character)
    (ambushing ?loc - location ?mon - character)
    (wellwished ?char - character)
    (islittlegirl ?char - character)
)
;define actions here
(:action move
    :parameters (?char - character ?from ?to ?by - location)
    :precondition (and (whereabouts ?from ?char) (not (imobile ?char)) (not (isdead ?char)) (not (isasleep ?char)) (not (oblivious ?to ?char)) (or (and (= ?to ?by) (atloc ?from ?to)) (and (= ?from ?by) (atloc ?to ?from)))
    (forall (?chart - character) (or (not (hate ?char ?chart)) (not (whereabouts ?to ?chart)) (isasleep ?chart)))
    (forall (?mon - monster) (and (not (ambushing ?from ?mon)) (not (ambushing ?to ?mon))))
    )
    :effect (and (not (whereabouts ?from ?char)) (whereabouts ?to ?char)
    )
)
(:action pick_up
    :parameters (?char - character ?item - item ?loc - location)
    :precondition (and (whereabouts ?loc ?char) (atloc ?item ?loc) (not (isdead ?char)) (not (isasleep ?char)) (not (cangobble ?char)))
    :effect (and (not (atloc ?item ?loc)) (inventory ?item ?char)
    )
)
(:action give
    :parameters (?char1 - character ?char2 - character ?item - consumable ?loc - location)
    :precondition (and (whereabouts ?loc ?char1) (whereabouts ?loc ?char2) (inventory ?item ?char1) (issick ?char2) (not (isdead ?char1)) (not (isasleep ?char1)) (not (hate ?char2 ?char1)) (not (cangobble ?char2))
    ) 
    :effect (and (not (inventory ?item ?char1)) (inventory ?item ?char2)
    )
)
(:action food_coma
    :parameters (?char - monster ?loc - location)
    :precondition (and (whereabouts ?loc ?char) (not (isasleep ?char)) (not (isdead ?char)) (not (ambushing ?loc ?char))
    (forall (?char1 - character) (or (not (whereabouts ?loc ?char1)) (not (hate ?char ?char1))) )
    )
    :effect (and (isasleep ?char)
    )
)
(:action share_info
    :parameters (?char1 - character ?char2 - character ?loc - location ?inf - location)
    :precondition (and (whereabouts ?loc ?char1) (whereabouts ?loc ?char2) (oblivious ?inf ?char1) (not (oblivious ?inf ?char2)) (not (isDead ?char1)) (not (isDead ?char2)) (not (hate ?char1 ?char2))
    (not (isasleep ?char1)) (not (isasleep ?char2))
    )
    :effect (and (not (oblivious ?inf ?char1))
    )
)
(:action swallow
    :parameters (?mon - monster ?vict - character ?loc - location)
    :precondition (and (whereabouts ?loc ?vict) (whereabouts ?loc ?mon) (cangobble ?mon) (not (= ?mon ?vict)) (not (hate ?mon ?vict)) (not (isDead ?mon)) (not (isasleep ?mon)) (not (inside ?vict ?mon)) (not (issaved ?vict)) (not (isweakened ?mon))
    (forall (?char - character) (or (not (whereabouts ?loc ?char)) (= ?char ?vict) (= ?char ?mon)))
    )
    :effect (and (inside ?vict ?mon) (imobile ?mon) (not (whereabouts ?loc ?vict))
    )
)
(:action cesarean
    :parameters (?char - character ?mon - monster ?bab - character ?cut - blade ?loc - location)
    :precondition (and (whereabouts ?loc ?char) (whereabouts ?loc ?mon) (inventory ?cut ?char) (inside ?bab ?mon) (not (= ?char ?mon)) (not (isasleep ?char)) (not (isdead ?char)) (isasleep ?mon)
    )
    :effect (and (not (inside ?bab ?mon)) (issaved ?bab) (whereabouts ?loc ?bab) (isweakened ?mon)
    )
)
(:action share_food
    :parameters (?char1 ?char2 - character ?item - consumable ?loc - location)
    :precondition (and (issick ?char1) (whereabouts ?loc ?char2) (inventory ?item ?char1) (whereabouts ?loc ?char1) (not (isdead ?char2)) (not (isasleep ?char2)) (not (cangobble ?char1)) (not (cangobble ?char2))
    (forall (?trap - trap) (and (atloc ?trap ?loc) (isset ?trap)))
    )
    :effect (and (not (inventory ?item ?char1)) (not (issick ?char1))
    )
)
(:action set_trap
    :parameters (?char - character ?trap - trap ?bait - consumable ?loc - location)
    :precondition (and (whereabouts ?loc ?char) (atloc ?trap ?loc) (inventory ?bait ?char)
    (forall (?mon - monster) (ambushing ?loc ?mon))
    )
    :effect (and (isset ?trap) (not (inventory ?bait ?char))
    )
)
(:action eat_bait
    :parameters (?mon - monster ?trap - trap ?loc - location)
    :precondition (and (whereabouts ?loc ?mon) (atloc ?trap ?loc) (isset ?trap) (not (isasleep ?mon)) (not (isdead ?mon)) (not (isweakened ?mon)))
    :effect (and (isweakened ?mon) (not (isset ?trap))
    )
)
(:action push_into_hazzard
    :parameters (?char1 - character ?mon - character ?haz - hazzard ?loc - location)
    :precondition (and (whereabouts ?loc ?char1) (whereabouts ?loc ?mon) (whereabouts ?loc ?mon) (atloc ?haz ?loc) (isweakened ?mon) (not (isdead ?char1)) (not (isdead ?mon))(not (= ?char1 ?mon)) (not (issick ?char1)) (not (islittlegirl ?char1))
    )
    :effect (and (isdead ?mon) (not (ambushing ?loc ?mon)) (not (isasleep ?mon)) (not (isweakened ?mon))
    )
)
(:action lay_ambush
    :parameters (?mon - monster ?loc - location)
    :precondition (and (whereabouts ?loc ?mon) (not (isdead ?mon)) (not (isasleep ?mon)) (not (ambushing ?loc ?mon)))
    :effect (and (ambushing ?loc ?mon) (imobile ?mon)
    )
)
(:action give_gift
    :parameters (?char1 ?char2 - character ?gift - gift ?loc - location)
    :precondition (and (whereabouts ?loc ?char1) (whereabouts ?loc ?char2) (inventory ?gift ?char1) (issick ?char2) (islittlegirl ?char1) (not (isdead ?char1)) (not (isdead ?char2)) (not (isasleep ?char1)) (not (hate ?char1 ?char2))
    )
    :effect (and (not (inventory ?gift ?char1)) (inventory ?gift ?char2) (wellwished ?char2))
)
)