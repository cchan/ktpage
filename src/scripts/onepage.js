$('a[href^="#"]').on('click', function(e) {
  console.log(this.hash);
  $('html, body').stop().animate({
    scrollTop: $(this.hash).offset().top
  }, 900, 'swing', (function(_this) {
    return function() {
      return window.location.hash = _this.hash;
    };
  })(this));
  return e.preventDefault();
});
