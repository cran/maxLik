(TeX-add-style-hook
 "stochastic-gradient-maxLik"
 (lambda ()
   (TeX-add-to-alist 'LaTeX-provided-package-options
                     '(("inputenc" "utf8")))
   (TeX-run-style-hooks
    "latex2e"
    "article"
    "art10"
    "graphics"
    "amsmath"
    "amssymb"
    "indentfirst"
    "inputenc"
    "natbib"
    "xspace")
   (TeX-add-symbols
    '("mat" 1)
    "elemProd"
    "maxlik"
    "transpose")
   (LaTeX-add-labels
    "sec:stochastic-gradient-ascent"
    "eq:full-batch-gradient"
    "eq:stochastic-gradient"
    "eq:minibatch-gradient"
    "sec:sga-in-maxlik"
    "sec:gradient-function"
    "sec:stopping-conditions"
    "sec:optimizers"
    "eq:gradient-update-momentum"
    "sec:control-options"
    "sec:example-usage-cases"
    "sec:setting-up"
    "eq:ols-gradient"
    "sec:training-validation"
    "sec:sequence-batch-sizes")
   (LaTeX-add-bibliographies
    "sga"))
 :latex)

