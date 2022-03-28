----------------------- MODULE step1d_fairness_not_ok -----------------------

(* By checking Termination property, this fails due to stuttering *)

EXTENDS TLC, Integers

Color == {"red", "green"}

NextColor(c) == CASE c = "red" -> "green"
                  [] c = "green" -> "red"
                  
(*--algorithm traffic

variables
  at_light = TRUE,
  light = "red";

fair process street_light = "light"
begin
  Cycle:
    while at_light do
      light := NextColor(light);
    end while;
end process;

fair process car = "car"
begin
  Drive:
    when light = "green";
    at_light := FALSE;
end process;
end algorithm;*)

\* BEGIN TRANSLATION (chksum(pcal) = "18beb5eb" /\ chksum(tla) = "dcb4f4ed")
VARIABLES at_light, light, pc

vars == << at_light, light, pc >>

ProcSet == {"light"} \cup {"car"}

Init == (* Global variables *)
        /\ at_light = TRUE
        /\ light = "red"
        /\ pc = [self \in ProcSet |-> CASE self = "light" -> "Cycle"
                                        [] self = "car" -> "Drive"]

Cycle == /\ pc["light"] = "Cycle"
         /\ IF at_light
               THEN /\ light' = NextColor(light)
                    /\ pc' = [pc EXCEPT !["light"] = "Cycle"]
               ELSE /\ pc' = [pc EXCEPT !["light"] = "Done"]
                    /\ light' = light
         /\ UNCHANGED at_light

street_light == Cycle

Drive == /\ pc["car"] = "Drive"
         /\ light = "green"
         /\ at_light' = FALSE
         /\ pc' = [pc EXCEPT !["car"] = "Done"]
         /\ light' = light

car == Drive

(* Allow infinite stuttering to prevent deadlock on termination. *)
Terminating == /\ \A self \in ProcSet: pc[self] = "Done"
               /\ UNCHANGED vars

Next == street_light \/ car
           \/ Terminating

Spec == /\ Init /\ [][Next]_vars
        /\ WF_vars(street_light)
        /\ WF_vars(car)

Termination == <>(\A self \in ProcSet: pc[self] = "Done")

\* END TRANSLATION 


=============================================================================
\* Modification History
\* Last modified Mon Mar 28 11:55:57 CEST 2022 by aricci
\* Created Sun Mar 28 12:25:02 CEST 2021 by aricci
