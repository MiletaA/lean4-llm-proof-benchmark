import Mathlib

lemma add_succ (n m : ℕ) : n + m + 1 = n + (m + 1) :=
  by induction m; rfl

theorem add_assoc_test (a b c : ℕ) :
  (a + b) + c = a + (b + c) := by
  induction c
  · rw [add_zero (a + b)]
    rw [add_zero b]
    rfl
  · congr
    rw [add_succ (a + b) c]
    rw [add_succ a (b + c)]
    rw [IH]
    rfl
