import Mathlib

theorem add_comm_test (a b : ℕ) :
  a + b = b + a := by
  induction a with
  | zero =>
    rw [zero_add]
    reflexivity
  | succ a' ih =>
    rw [succ_add]
    rw [add_comm b a']
    rw [ih]
    reflexivity
