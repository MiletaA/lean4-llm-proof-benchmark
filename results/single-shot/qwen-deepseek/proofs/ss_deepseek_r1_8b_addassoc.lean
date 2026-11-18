import Mathlib

theorem add_assoc_test (a b c : ℕ) :
  (a + b) + c = a + (b + c) := by
induction c with
| zero =>
  rw [Nat.add_zero, Nat.add_zero]
| succ k =>
  induction b with
  | zero =>
    rw [Nat.add_succ, Nat.add_succ] <;> apply_instance
    -- Simplify using the definitions and induction hypothesis
    simp only [Nat.add_succ, Nat.add_succ, add_assoc_test]
    ring_nf
