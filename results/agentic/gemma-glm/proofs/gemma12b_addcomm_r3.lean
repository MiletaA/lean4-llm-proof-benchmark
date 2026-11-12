import Mathlib

theorem add_comm_test (a b : ℕ) :
  a + b = b + a := by
  induction a with
  | zero =>
    rw [zero_add]
    simp
  | succ a' ih =>
    rw [add_succ]
    rw [ih]
    simp
