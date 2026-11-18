import Mathlib

-- Helper lemma to prove addition is commutative for natural numbers
lemma add_comm_helper (a b : ℕ) : a + b = b + a := by
  induction a with
  | zero => rw [zero_add, add_zero]
  | succ n ih => rw [add_succ, ih, succ_add]

theorem add_comm_test (a b : ℕ) :
  a + b = b + a :=
add_comm_helper a b
