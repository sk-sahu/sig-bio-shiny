library(magick)
library(hexSticker)

#img <- image_read('inst/figures/test.png')

# testing
sticker(~barplot(mtcars$mpg) , package="SigBio", p_size=20, s_x=.8, s_y=.6, s_width=1.4, s_height=1.2,
        h_fill = "#b968f7", h_color = "#f5f768",
        filename="inst/figures/sigbio_logo.png")
