.onAttach <- function(libname, pkgname) {
  setHook(packageEvent("annmatrix", "attach"), function(...) {
    mySlotNames <- function(x) {
      if(is.annmatrix(x)) {
        names(rowanns(x))
      } else {
        slotNames(x)
      }
    }

    ns <- asNamespace("methods")
    unlockBinding("slotNames", ns)
    ns[["slotNames"]] <- mySlotNames
    lockBinding("slotNames", ns)
  })
}

