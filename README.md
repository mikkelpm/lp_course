# Local projections for applied macroeconomics

This repo contains lecture materials for a short course (~5 hours) on the practical implementation of local projections for applied macroeconomics.

The slides emphasize hands-on coding tools and intuitive concepts rather than math. I prioritize simplicity of implementation in Stata over cutting-edge econometric performance (but I give references to cutting-edge papers). My running example is based on the empirical application in [Bilal & Känzig (2026)](https://github.com/dkaenzig/micc_replication).

**This is not a first course on local projections**. I assume basic familiarity with concepts such as impulse responses and some exposure to basic local projections and structural VARs. Good additional resources include [Diego Känzig's lecture slides](https://github.com/dkaenzig/empiricalMacro_PhDcourse), the chapters in the 2016 Handbook of Macroeconomics by [Valerie Ramey](https://doi.org/10.1016/bs.hesmac.2016.03.003) and [Stock & Watson](https://doi.org/10.1016/bs.hesmac.2016.04.002), and the 2025 *JEL* article by [Jordà & Taylor](https://doi.org/10.1257/jel.20241521).

The materials have not yet been thoroughly vetted. If you spot any errors or confusing parts, I would be grateful if you could create a GitHub Issue or [email me](mailto:mikkelpm@uchicago.edu).

## Contents
- [Lecture 1](slides/lecture1.pdf) ([Stata do-file](stata/lecture1.do))
  - Control variables, identification by timing restrictions
  - Standard errors, pointwise confidence intervals
  - Variance decompositions
  - Proxies/instruments
  - Other identification schemes
- [Lecture 2](slides/lecture2.pdf)
  - Comparison between local projections and VARs
- [Lecture 3](slides/lecture3.pdf) ([Stata do-file](stata/lecture3.do))
  - Simultaneous confidence bands
  - Shrinkage estimation
  - Bias correction
  - Bootstrap
- [Reading list](readings/reading_list.pdf)

## Omissions
This course does *not* cover the following important topics:
- Basic introduction to dynamic causal effects and local projections
- Introduction to structural VARs
- Panel data
- Nonlinear specifications
- Weak instruments

My quarter-length course "[Econometric Methods for Macroeconomics](https://github.com/mikkelpm/macro_econometrics)" covers some of these topics.

## Acknowledgements
This material is based upon work supported by the NSF under [Grant #2238049](https://www.nsf.gov/awardsearch/showAward?AWD_ID=2238049) and by the Alfred P. Sloan Foundation.