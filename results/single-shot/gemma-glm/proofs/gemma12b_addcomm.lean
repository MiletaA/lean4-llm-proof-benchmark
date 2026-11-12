import Mathlib

theorem add_comm_test (a b : ℕ) :
  a + b = b + a := by
  induction a with a' ih
  · simp
  · simp [Nat.add_succ_eq, ih]
