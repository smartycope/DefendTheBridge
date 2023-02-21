extends LineEdit

func submitted():
    self.placeholder_text = self.text
    self.text = ''
