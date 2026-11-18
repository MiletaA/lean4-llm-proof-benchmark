import Mathlib

-- Helper lemma to establish commutativity of addition for natural numbers
lemma nat_add_comm (a b : ℕ) : a + b = b + a :=
begin
  induction a with d hd,
  { -- Base case: a = 0
    rw [zero_add, add_zero],
  },
  { -- Inductive step: a = d + 1
    rw [Nat.add_succ, Nat.succ_add],
    exact hd b,
  }
end

theorem add_comm_test (a b : ℕ) :
  a + b = b + a :=
begin
  apply nat_add_comm,
end
