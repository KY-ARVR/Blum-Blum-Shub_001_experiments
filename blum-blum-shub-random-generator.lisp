﻿;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 
;; This file contains several experiments conducted with methods to
;; implement the Blum-Blum-Shub random number generator.
;; 
;; ---------------------------------------------------------------------
;; 
;; Author: Kaveh Yousefi
;; 
;; Date: 2020-01-14
;; 
;; Sources:
;;   -> "https://en.wikipedia.org/wiki/Blum_Blum_Shub"
;;   -> "https://de.wikipedia.org/wiki/Blum-Blum-Shub-Generator"
;;   -> "https://github.com/OverStruck/blum-blum-shub-prbg/blob/master/bbs.cpp"
;;   -> "https://code.google.com/p/javarng/"
;; 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; -- Test 01: Simple sequence.                                    -- ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun make-blum-blum-shub-generator (&key p q seed)
  (let ((M (* p q)))
    (let ((x0 seed))
      #'(lambda ()
          (setf x0 (mod (* x0 x0) M))
          x0))))

;;; -------------------------------------------------------

(let ((random-generator (make-blum-blum-shub-generator :p 11 :q 19 :seed 3)))
  (loop repeat 7 do
    (print (funcall random-generator))))



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; -- Test 02: With "bitnum".                                      -- ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun bitnum (bits)
  "Returns the number of 1-bits which comprimise the integer-encoded BITS."
  (let ((number-of-bits (integer-length bits)))
    (loop
      for  bit-index from 0 below number-of-bits
      when (logbitp bit-index bits)
      sum  1)))

;;; -------------------------------------------------------

;; Output is based upon the parity bit.
(defun make-blum-blum-shub-generator (&key p q seed)
  (let ((M (* p q)))
    (let ((x0 seed))
      #'(lambda ()
          (setf x0 (mod (* x0 x0) M))
          (list x0 (bitnum (mod x0 2)))))))

;;; -------------------------------------------------------

(let ((random-generator (make-blum-blum-shub-generator :p 7 :q 11 :seed 64)))
  (loop repeat 7 do
    (print (funcall random-generator))))



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; -- Test 03: With least significant bit.                         -- ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Output is based upon the least significant bit.
(defun make-blum-blum-shub-generator (&key p q seed)
  (let ((M (* p q)))
    (let ((x0 seed))
      #'(lambda ()
          (setf x0 (mod (* x0 x0) M))
          (list x0 (if (logbitp 0 x0) 1 0))))))

;;; -------------------------------------------------------

(let ((random-generator (make-blum-blum-shub-generator :p 11 :q 19 :seed 3)))
  (loop repeat 7 do
    (print (funcall random-generator))))



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; -- Test 04: Object-oriented design.                             -- ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defstruct (Blum-Blum-Shub-Random-Generator
  (:constructor make-blum-blum-shub-random-generator (&key p q (M (* p q)) seed (x0 seed))))
  (p    0 :type integer)
  (q    0 :type integer)
  (M    0 :type integer)
  (seed 0 :type integer)
  (x0   0 :type integer))

;;; -------------------------------------------------------

;; Output is based upon the least significant bit.
(defun get-next-random-number (blum-blum-shub-generator)
  (with-slots (x0 M) blum-blum-shub-generator
    (setf x0 (mod (* x0 x0) M))
    (let ((output (ldb (byte 1 0) x0)))
      (list output x0))))

;;; -------------------------------------------------------

(let ((random-generator (make-blum-blum-shub-random-generator :p 11 :q 19 :seed 3)))
  (loop repeat 7 do
    (print (get-next-random-number random-generator))))



