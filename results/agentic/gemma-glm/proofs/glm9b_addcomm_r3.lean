import Mathlib

theorem add_comm (m n : ℕ) : m + n = n + m := by induction n; simp [add_zero]

lemma add_assoc_left (m n p : ℕ) : (m + n) + p = m + (n + p) := by simp [add_assoc]

lemma add_assoc_right (m n p : ℕ) : m + (n + p) = (m + n) + p := by simp [add_assoc]

-- The actual test theorem
theorem add_comm_test (a b : ℕ) :
  a + b = b + a := by induction a with H_a; induction b; simp [add_zero, add_assoc_left, add_assoc_right] using H_a
