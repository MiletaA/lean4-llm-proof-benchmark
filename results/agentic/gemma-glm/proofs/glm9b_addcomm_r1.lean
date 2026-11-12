import Mathlib

-- Helper lemma for proving associativity
lemma add_assoc (a b c : ℕ) : (a + b) + c = a + (b + c) := by
  apply nat.add_comm; simp [add_comm]

-- Proof of add_comm_test
theorem add_comm_test (a b : ℕ) :
  a + b = b + a := by
  -- Apply the commutativity property of addition from Nat, which is `nat.add_comm`
  rw [nat.add_comm]
