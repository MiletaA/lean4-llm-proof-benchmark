import Mathlib

theorem add_assoc_test (a b c : ℕ) :
  (a + b) + c = a + (b + c) := by
  cases a with
  | 0 =>
    cases b with
    | 0 =>
      cases c with
      | 0 =>
        rw [Nat.zero_add]
        rw [Nat.zero_add]
        rw [Nat.zero_add]
      | c' =>
        rw [Nat.zero_add]
        rw [Nat.zero_add]
        rw [Nat.zero_add]
    | b' =>
      rw [Nat.zero_add]
      rw [Nat.zero_add]
      rw [Nat.zero_add]
  | a' =>
    cases b with
    | 0 =>
      cases c with
      | 0 =>
        rw [Nat.succ_add]
        rw [Nat.succ_add]
        rw [Nat.succ_add]
      | c' =>
        rw [Nat.succ_add]
        rw [Nat.succ_add]
        rw [Nat.succ_add]
    | b' =>
      rw [Nat.succ_add]
      rw [Nat.succ_add]
      rw [Nat.succ_add]
