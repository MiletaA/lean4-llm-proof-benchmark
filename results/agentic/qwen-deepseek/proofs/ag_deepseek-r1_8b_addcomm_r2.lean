import Mathlib

theorem add_comm_test (a b : ℕ) :
  a + b = b + a := by
    induction a with
    | zero =>
      intro h_b
      rw [Nat.zero_add, Nat.add_zero]
    | succ m' => 
      intro h_b
      rw [← Nat.add_succ] at h_b
      cases b with
      | zero =>
        rw [Nat.add_zero, Nat.zero_add]
      | succ n' =>
        apply (m').add_comm n'
