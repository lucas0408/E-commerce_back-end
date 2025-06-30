let Hooks = {}

function applyMask(el, formatter) {
  el.addEventListener("input", (e) => {
    const digits = el.value.replace(/\D/g, "")
    el.value = formatter(digits)
  })

  el.form?.addEventListener("submit", () => {
    el.value = el.value.replace(/\D/g, "")
  })
}

Hooks.CepMask = {
    mounted() {
        this.apply()
      },
    updated() {
        this.apply()
      },
    apply() {
        applyMask(this.el, (v) => {
        return v.length > 5 ? v.replace(/^(\d{5})(\d{0,3})/, "$1-$2") : v
        })
    }
}

Hooks.CpfMask = {
    mounted() {
        this.apply()
      },
    updated() {
        this.apply()
      },
    apply() {
        applyMask(this.el, (v) => {
        return v
            .replace(/^(\d{3})(\d)/, "$1.$2")
            .replace(/^(\d{3})\.(\d{3})(\d)/, "$1.$2.$3")
            .replace(/\.(\d{3})(\d)/, ".$1-$2")
        })
    }
}

Hooks.PhoneMask = {
    mounted() {
        this.apply()
      },
    updated() {
        this.apply()
      },
    apply(){
        applyMask(this.el, (v) => {
        if (v.length <= 10) {
            return v
            .replace(/^(\d{2})(\d)/, "($1) $2")
            .replace(/(\d{4})(\d)/, "$1-$2")
        } else {
            return v
            .replace(/^(\d{2})(\d)/, "($1) $2")
            .replace(/(\d{5})(\d)/, "$1-$2")
        }
      })
   }
}

Hooks.CnpjMask = {
    mounted() {
      this.apply()
    },
    updated() {
      this.apply()
    },
    apply() {
      applyMask(this.el, (v) => {
        return v
          .replace(/^(\d{2})(\d)/, "$1.$2")
          .replace(/^(\d{2})\.(\d{3})(\d)/, "$1.$2.$3")
          .replace(/\.(\d{3})(\d)/, ".$1/$2")
          .replace(/(\d{4})(\d)/, "$1-$2")
      })
    }
  }

export default Hooks
