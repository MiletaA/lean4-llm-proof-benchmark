import Mathlib

-- Helper lemma to prove associativity of addition for natural numbers
lemma add_assoc_helper (a b c : ℕ) :
  (a + b) + c = a + (b + c) := by
  induction a with
  | zero =>
    rw [zero_add, zero_add]
  | succ n ih =>
    rw [succ_add, succ_add, ih]

-- Add the missing lemma for succ_add
lemma succ_add (n m : ℕ) : succ n + m = succ (n + m) := rfl

theorem add_assoc_test (a b c : ℕ) :
  (a + b) + c = a + (b + c) :=
  add_assoc_helper a b c
