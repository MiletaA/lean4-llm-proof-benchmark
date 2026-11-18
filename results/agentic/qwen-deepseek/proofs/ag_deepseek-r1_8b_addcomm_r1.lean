import Mathlib

theorem add_comm_test (a b : ℕ) :
  a + b = b + a := by
    cases a generalizing b <;>
      intro h
    · -- base case: a = 0
      rw [Nat.add_zero, Nat.zero_add]
      rfl
      
    · -- inductive step: a = succ(m)
      have : (a.pred + b) = (b + a.pred) := by apply ih; assumption
      cases goal;
        intro h'; 
          simp only [Nat.add_succ] at goal;
          rw [this] at goal;
          rfl
