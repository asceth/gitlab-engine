var Loader = {
  img_src: "/assets/gitlab_engine/ajax-loader.gif",

  html:
    function(width) {
      img = $("<img>");
      img.attr("width", width);
      img.attr("src", this.img_src);
      return img;
    }
}
