import Mathlib

theorem add_comm_test (a b : ℕ) :
  a + b = b + a := by
  induction a
  · rw [Nat.add_zero, Nat.zero_add]
    rfl
  · rw [Nat.add_succ, Nat.add_succ]
    congr
    exact ih
