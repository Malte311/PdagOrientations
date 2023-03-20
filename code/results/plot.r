library(ggplot2)
library(dplyr)
library(patchwork)
library(stringr)
library(tikzDevice)

data_ext_chord = read.csv(file = "results-ext-chordal.csv", sep=",", dec=".")
#data_ext_cpdag = read.csv(file = "results-ext-cpdag.csv", sep=",", dec=".")
data_ext_pdag = read.csv(file = "results-ext-pdag.csv", sep=",", dec=".")
#data_mo_cpdag = read.csv(file = "results-maxorient-cpdag.csv", sep=",", dec=".")
data_mo_pdag = read.csv(file = "results-maxorient-pdag.csv", sep=",", dec=".")

data_ext_chord["algo"][data_ext_chord["algo"] == "pdag2dag_dt"] = "\\textsc{dt}"
#data_ext_cpdag["algo"][data_ext_cpdag["algo"] == "pdag2dag_dt"] = "\\textsc{dt}"
data_ext_pdag["algo"][data_ext_pdag["algo"] == "pdag2dag_dt"] = "\\textsc{dt}"
data_ext_chord["algo"][data_ext_chord["algo"] == "pdag2dag_dtch"] = "\\textsc{dtic}"
#data_ext_cpdag["algo"][data_ext_cpdag["algo"] == "pdag2dag_dtch"] = "\\textsc{dtic}"
data_ext_pdag["algo"][data_ext_pdag["algo"] == "pdag2dag_dtch"] = "\\textsc{dtic}"
data_ext_chord["algo"][data_ext_chord["algo"] == "pdag2dag_dth"] = "\\textsc{dth}"
#data_ext_cpdag["algo"][data_ext_cpdag["algo"] == "pdag2dag_dth"] = "\\textsc{dth}"
data_ext_pdag["algo"][data_ext_pdag["algo"] == "pdag2dag_dth"] = "\\textsc{dth}"
data_ext_chord["algo"][data_ext_chord["algo"] == "pdag2dag_wbl"] = "\\textsc{wbl}"
#data_ext_cpdag["algo"][data_ext_cpdag["algo"] == "pdag2dag_wbl"] = "\\textsc{wbl}"
data_ext_pdag["algo"][data_ext_pdag["algo"] == "pdag2dag_wbl"] = "\\textsc{wbl}"

data_ext_chord = rename(data_ext_chord, "Algorithm" = "algo")
#data_ext_cpdag = rename(data_ext_cpdag, "Algorithm" = "algo")
data_ext_pdag = rename(data_ext_pdag, "Algorithm" = "algo")
#data_mo_cpdag = rename(data_mo_cpdag, "Algorithm" = "algo")
data_mo_pdag = rename(data_mo_pdag, "Algorithm" = "algo")

data_mo_pdag_bar = data_mo_pdag
data_mo_pdag_bar = filter(data_mo_pdag_bar, Algorithm == "fastmeek")
data_mo_pdag_bar = filter(data_mo_pdag_bar, grepl("-avg.gr", file, fixed = TRUE))

data_mo_pdag = filter(
  data_mo_pdag,
  (Algorithm == "fastmeek" & type == "total") | (Algorithm == "meek" & type == "1")
)

#data_mo_cpdag = filter(
#  data_mo_cpdag,
#  (Algorithm == "fastmeek" & type == "total") | (Algorithm == "meek" & type == "1")
#)

data_mo_pdag["Algorithm"][data_mo_pdag["Algorithm"] == "meek"] = "\\textsc{direct-meek}"
data_mo_pdag["Algorithm"][data_mo_pdag["Algorithm"] == "fastmeek"] = "\\textsc{ce-meek}"

data_ext_chord_avg = filter(data_ext_chord, grepl("-avg.gr", file, fixed = TRUE))
#data_ext_cpdag_ba_avg = filter(data_ext_cpdag, grepl("-ba-avg.gr", file, fixed = TRUE))
#data_ext_cpdag_er_avg = filter(data_ext_cpdag, grepl("-er-avg.gr", file, fixed = TRUE))
data_ext_pdag_ba_avg = filter(data_ext_pdag, grepl("-ba-avg.gr", file, fixed = TRUE))
data_ext_pdag_er_avg = filter(data_ext_pdag, grepl("-er-avg.gr", file, fixed = TRUE))
#data_mo_cpdag_ba_avg = filter(data_mo_cpdag, grepl("-ba-avg.gr", file, fixed = TRUE))
#data_mo_cpdag_er_avg = filter(data_mo_cpdag, grepl("-er-avg.gr", file, fixed = TRUE))
data_mo_pdag_ba_avg = filter(data_mo_pdag, grepl("-ba-avg.gr", file, fixed = TRUE))
data_mo_pdag_er_avg = filter(data_mo_pdag, grepl("-er-avg.gr", file, fixed = TRUE))

data_ext_chord_avg_m1 = filter(
  data_ext_chord_avg,
  grepl("chordal-\\d{1,4}-03-avg\\.gr", file)
)
data_ext_chord_avg_m2 = filter(
  data_ext_chord_avg,
  unlist(Map(function(x, y)
    grepl(paste(
      "chordal-\\d{1,4}-",
      str_pad(paste(round(log2(strtoi(x)), digits=0)), 2, "left", "0"),
      "-avg\\.gr",
      sep=""
    ), y),
    n,
    file
  ))
)
data_ext_chord_avg_m3 = filter(
  data_ext_chord_avg,
  grepl("chordal-\\d{1,4}-05-avg\\.gr", file)
)
data_ext_chord_avg_m4 = filter(
  data_ext_chord_avg,
  unlist(Map(function(x, y)
    grepl(paste(
      "chordal-\\d{1,4}-",
      str_pad(paste(round(sqrt(strtoi(x)), digits=0)), 2, "left", "0"),
      "-avg\\.gr",
      sep=""
    ), y),
    n,
    file
  ))
)


#data_ext_cpdag_ba_avg_m1 = filter(data_ext_cpdag_ba_avg, m == 3*n)
#data_ext_cpdag_ba_avg_m2 = filter(data_ext_cpdag_ba_avg, m == round(log2(n), digits=0)*n)

#data_ext_cpdag_er_avg_m1 = filter(data_ext_cpdag_er_avg, m == 3*n)
#data_ext_cpdag_er_avg_m2 = filter(data_ext_cpdag_er_avg, m == round(log2(n), digits=0)*n)

data_ext_pdag_ba_avg_m1 = filter(data_ext_pdag_ba_avg, m == 3*n)
data_ext_pdag_ba_avg_m2 = filter(data_ext_pdag_ba_avg, m == round(log2(n), digits=0)*n)
data_ext_pdag_ba_avg_m3 = filter(data_ext_pdag_ba_avg, m == 5*n)
data_ext_pdag_ba_avg_m4 = filter(data_ext_pdag_ba_avg, m == round(sqrt(n), digits=0)*n)

data_ext_pdag_er_avg_m1 = filter(data_ext_pdag_er_avg, m == 3*n)
data_ext_pdag_er_avg_m2 = filter(data_ext_pdag_er_avg, m == round(log2(n), digits=0)*n)
data_ext_pdag_er_avg_m3 = filter(data_ext_pdag_er_avg, m == 5*n)
data_ext_pdag_er_avg_m4 = filter(data_ext_pdag_er_avg, m == round(sqrt(n), digits=0)*n)

#data_mo_cpdag_ba_avg_m1 = filter(data_mo_cpdag_ba_avg, m == 3*n)
#data_mo_cpdag_ba_avg_m2 = filter(data_mo_cpdag_ba_avg, m == round(log2(n), digits=0)*n)

#data_mo_cpdag_er_avg_m1 = filter(data_mo_cpdag_er_avg, m == 3*n)
#data_mo_cpdag_er_avg_m2 = filter(data_mo_cpdag_er_avg, m == round(log2(n), digits=0)*n)

data_mo_pdag_ba_avg_m1 = filter(data_mo_pdag_ba_avg, m == 3*n)
data_mo_pdag_ba_avg_m2 = filter(data_mo_pdag_ba_avg, m == round(log2(n), digits=0)*n)
data_mo_pdag_ba_avg_m3 = filter(data_mo_pdag_ba_avg, m == 5*n)
data_mo_pdag_ba_avg_m4 = filter(data_mo_pdag_ba_avg, m == round(sqrt(n), digits=0)*n)

data_mo_pdag_er_avg_m1 = filter(data_mo_pdag_er_avg, m == 3*n)
data_mo_pdag_er_avg_m2 = filter(data_mo_pdag_er_avg, m == round(log2(n), digits=0)*n)
data_mo_pdag_er_avg_m3 = filter(data_mo_pdag_er_avg, m == 5*n)
data_mo_pdag_er_avg_m4 = filter(data_mo_pdag_er_avg, m == round(sqrt(n), digits=0)*n)

p1 <- ggplot(data_ext_chord_avg_m1, aes(x=file, y=mean, group=Algorithm, color=Algorithm)) +
  geom_line(aes(group=Algorithm, linetype=Algorithm, color=Algorithm)) +
  geom_point(aes(shape=Algorithm, color=Algorithm)) +
  ggtitle("$k = 3$") +
  xlab("$n$") +
  ylab("time (ms)") +
  theme_classic() +
  theme(
    axis.line.x = element_line(arrow = grid::arrow(length = unit(0.1, "cm"))),
    axis.line.y = element_line(arrow = grid::arrow(length = unit(0.1, "cm")))
  ) +
  scale_y_log10() +
  scale_x_discrete(labels = function(x) gsub('[a-z]{4,7}-0{0,3}(\\d{1,4})-.*', '\\1', x)) +
  scale_color_manual(values=c(
    rgb(247,192,26, maxColorValue=255),
    rgb(37,122,164, maxColorValue=255),
    rgb(78,155,133, maxColorValue=255),
    rgb(86,51,94, maxColorValue=255)
  ))

p2 <- ggplot(data_ext_chord_avg_m2, aes(x=file, y=mean, group=Algorithm, color=Algorithm)) +
  geom_line(aes(group=Algorithm, linetype=Algorithm, color=Algorithm)) +
  geom_point(aes(shape=Algorithm, color=Algorithm)) +
  ggtitle("$k = \\log_2(n)$") +
  xlab("$n$") +
  ylab("time (ms)") +
  theme_classic() +
  theme(
    axis.line.x = element_line(arrow = grid::arrow(length = unit(0.1, "cm"))),
    axis.line.y = element_line(arrow = grid::arrow(length = unit(0.1, "cm")))
  ) +
  scale_y_log10() +
  scale_x_discrete(labels = function(x) gsub('[a-z]{4,7}-0{0,3}(\\d{1,4})-.*', '\\1', x)) +
  scale_color_manual(values=c(
    rgb(247,192,26, maxColorValue=255),
    rgb(37,122,164, maxColorValue=255),
    rgb(78,155,133, maxColorValue=255),
    rgb(86,51,94, maxColorValue=255)
  ))

p1b <- ggplot(data_ext_chord_avg_m3, aes(x=file, y=mean, group=Algorithm, color=Algorithm)) +
  geom_line(aes(group=Algorithm, linetype=Algorithm, color=Algorithm)) +
  geom_point(aes(shape=Algorithm, color=Algorithm)) +
  ggtitle("$k = 5$") +
  xlab("$n$") +
  ylab("time (ms)") +
  theme_classic() +
  theme(
    axis.line.x = element_line(arrow = grid::arrow(length = unit(0.1, "cm"))),
    axis.line.y = element_line(arrow = grid::arrow(length = unit(0.1, "cm")))
  ) +
  scale_y_log10() +
  scale_x_discrete(labels = function(x) gsub('[a-z]{4,7}-0{0,3}(\\d{1,4})-.*', '\\1', x)) +
  scale_color_manual(values=c(
    rgb(247,192,26, maxColorValue=255),
    rgb(37,122,164, maxColorValue=255),
    rgb(78,155,133, maxColorValue=255),
    rgb(86,51,94, maxColorValue=255)
  ))

p2b <- ggplot(data_ext_chord_avg_m4, aes(x=file, y=mean, group=Algorithm, color=Algorithm)) +
  geom_line(aes(group=Algorithm, linetype=Algorithm, color=Algorithm)) +
  geom_point(aes(shape=Algorithm, color=Algorithm)) +
  ggtitle("$k = \\sqrt n$") +
  xlab("$n$") +
  ylab("time (ms)") +
  theme_classic() +
  theme(
    axis.line.x = element_line(arrow = grid::arrow(length = unit(0.1, "cm"))),
    axis.line.y = element_line(arrow = grid::arrow(length = unit(0.1, "cm")))
  ) +
  scale_y_log10() +
  scale_x_discrete(labels = function(x) gsub('[a-z]{4,7}-0{0,3}(\\d{1,4})-.*', '\\1', x)) +
  scale_color_manual(values=c(
    rgb(247,192,26, maxColorValue=255),
    rgb(37,122,164, maxColorValue=255),
    rgb(78,155,133, maxColorValue=255),
    rgb(86,51,94, maxColorValue=255)
  ))

#pdf(file = "results-ext-chordal.pdf", height = 4.8)
tikz('results-ext-chordal.tex', standAlone = FALSE, height = 4.8)
p1 + p1b + p2 + p2b +
  plot_layout(ncol = 2, nrow = 2, guides = "collect") &
  theme(
    legend.position = "bottom",
    plot.title = element_text(size=11),
    axis.text = element_text(size=11)
  )
dev.off()

p3 <- ggplot(data_ext_pdag_ba_avg_m1, aes(x=file, y=mean, group=Algorithm, color=Algorithm)) +
  geom_line(aes(group=Algorithm, linetype=Algorithm, color=Algorithm)) +
  geom_point(aes(shape=Algorithm, color=Algorithm)) +
  ggtitle("$m = 3 \\cdot n$") +
  xlab("$n$") +
  ylab("time (ms)") +
  theme_classic() +
  theme(
    axis.line.x = element_line(arrow = grid::arrow(length = unit(0.1, "cm"))),
    axis.line.y = element_line(arrow = grid::arrow(length = unit(0.1, "cm")))
  ) +
  scale_x_discrete(labels = function(x) gsub('[a-z]{4,7}-0{0,3}(\\d{1,4})-.*', '\\1', x)) +
  scale_color_manual(values=c(
    rgb(247,192,26, maxColorValue=255),
    rgb(37,122,164, maxColorValue=255),
    rgb(78,155,133, maxColorValue=255),
    rgb(86,51,94, maxColorValue=255)
  ))

p4 <- ggplot(data_ext_pdag_ba_avg_m2, aes(x=file, y=mean, group=Algorithm, color=Algorithm)) +
  geom_line(aes(group=Algorithm, linetype=Algorithm, color=Algorithm)) +
  geom_point(aes(shape=Algorithm, color=Algorithm)) +
  ggtitle("$m = \\log_2(n) \\cdot n$") +
  xlab("$n$") +
  ylab("time (ms)") +
  theme_classic() +
  theme(
    axis.line.x = element_line(arrow = grid::arrow(length = unit(0.1, "cm"))),
    axis.line.y = element_line(arrow = grid::arrow(length = unit(0.1, "cm")))
  ) +
  scale_x_discrete(labels = function(x) gsub('[a-z]{4,7}-0{0,3}(\\d{1,4})-.*', '\\1', x)) +
  scale_color_manual(values=c(
    rgb(247,192,26, maxColorValue=255),
    rgb(37,122,164, maxColorValue=255),
    rgb(78,155,133, maxColorValue=255),
    rgb(86,51,94, maxColorValue=255)
  ))

p3b <- ggplot(data_ext_pdag_ba_avg_m3, aes(x=file, y=mean, group=Algorithm, color=Algorithm)) +
  geom_line(aes(group=Algorithm, linetype=Algorithm, color=Algorithm)) +
  geom_point(aes(shape=Algorithm, color=Algorithm)) +
  ggtitle("$m = 5 \\cdot n$") +
  xlab("$n$") +
  ylab("time (ms)") +
  theme_classic() +
  theme(
    axis.line.x = element_line(arrow = grid::arrow(length = unit(0.1, "cm"))),
    axis.line.y = element_line(arrow = grid::arrow(length = unit(0.1, "cm")))
  ) +
  scale_x_discrete(labels = function(x) gsub('[a-z]{4,7}-0{0,3}(\\d{1,4})-.*', '\\1', x)) +
  scale_color_manual(values=c(
    rgb(247,192,26, maxColorValue=255),
    rgb(37,122,164, maxColorValue=255),
    rgb(78,155,133, maxColorValue=255),
    rgb(86,51,94, maxColorValue=255)
  ))

p4b <- ggplot(data_ext_pdag_ba_avg_m4, aes(x=file, y=mean, group=Algorithm, color=Algorithm)) +
  geom_line(aes(group=Algorithm, linetype=Algorithm, color=Algorithm)) +
  geom_point(aes(shape=Algorithm, color=Algorithm)) +
  ggtitle("$m = \\sqrt n \\cdot n$") +
  xlab("$n$") +
  ylab("time (ms)") +
  theme_classic() +
  theme(
    axis.line.x = element_line(arrow = grid::arrow(length = unit(0.1, "cm"))),
    axis.line.y = element_line(arrow = grid::arrow(length = unit(0.1, "cm")))
  ) +
  scale_x_discrete(labels = function(x) gsub('[a-z]{4,7}-0{0,3}(\\d{1,4})-.*', '\\1', x)) +
  scale_color_manual(values=c(
    rgb(247,192,26, maxColorValue=255),
    rgb(37,122,164, maxColorValue=255),
    rgb(78,155,133, maxColorValue=255),
    rgb(86,51,94, maxColorValue=255)
  ))

#pdf(file = "results-ext-pdag-ba.pdf", height = 4.8)
tikz('results-ext-pdag-ba.tex', standAlone = FALSE, height = 4.8)
p3 + p3b + p4 + p4b +
  plot_layout(ncol = 2, nrow = 2, guides = "collect") &
  theme(
    legend.position = "bottom",
    plot.title = element_text(size=11),
    axis.text = element_text(size=11)
  )
dev.off()

p5 <- ggplot(data_ext_pdag_er_avg_m1, aes(x=file, y=mean, group=Algorithm, color=Algorithm)) +
  geom_line(aes(group=Algorithm, linetype=Algorithm, color=Algorithm)) +
  geom_point(aes(shape=Algorithm, color=Algorithm)) +
  ggtitle("$m = 3 \\cdot n$") +
  xlab("$n$") +
  ylab("time (ms)") +
  theme_classic() +
  theme(
    axis.line.x = element_line(arrow = grid::arrow(length = unit(0.1, "cm"))),
    axis.line.y = element_line(arrow = grid::arrow(length = unit(0.1, "cm")))
  ) +
  scale_x_discrete(labels = function(x) gsub('[a-z]{4,7}-0{0,3}(\\d{1,4})-.*', '\\1', x)) +
  scale_color_manual(values=c(
    rgb(247,192,26, maxColorValue=255),
    rgb(37,122,164, maxColorValue=255),
    rgb(78,155,133, maxColorValue=255),
    rgb(86,51,94, maxColorValue=255)
  ))

p6 <- ggplot(data_ext_pdag_er_avg_m2, aes(x=file, y=mean, group=Algorithm, color=Algorithm)) +
  geom_line(aes(group=Algorithm, linetype=Algorithm, color=Algorithm)) +
  geom_point(aes(shape=Algorithm, color=Algorithm)) +
  ggtitle("$m = \\log_2(n) \\cdot n$") +
  xlab("$n$") +
  ylab("time (ms)") +
  theme_classic() +
  theme(
    axis.line.x = element_line(arrow = grid::arrow(length = unit(0.1, "cm"))),
    axis.line.y = element_line(arrow = grid::arrow(length = unit(0.1, "cm")))
  ) +
  scale_x_discrete(labels = function(x) gsub('[a-z]{4,7}-0{0,3}(\\d{1,4})-.*', '\\1', x)) +
  scale_color_manual(values=c(
    rgb(247,192,26, maxColorValue=255),
    rgb(37,122,164, maxColorValue=255),
    rgb(78,155,133, maxColorValue=255),
    rgb(86,51,94, maxColorValue=255)
  ))

p5b <- ggplot(data_ext_pdag_er_avg_m3, aes(x=file, y=mean, group=Algorithm, color=Algorithm)) +
  geom_line(aes(group=Algorithm, linetype=Algorithm, color=Algorithm)) +
  geom_point(aes(shape=Algorithm, color=Algorithm)) +
  ggtitle("$m = 5 \\cdot n$") +
  xlab("$n$") +
  ylab("time (ms)") +
  theme_classic() +
  theme(
    axis.line.x = element_line(arrow = grid::arrow(length = unit(0.1, "cm"))),
    axis.line.y = element_line(arrow = grid::arrow(length = unit(0.1, "cm")))
  ) +
  scale_x_discrete(labels = function(x) gsub('[a-z]{4,7}-0{0,3}(\\d{1,4})-.*', '\\1', x)) +
  scale_color_manual(values=c(
    rgb(247,192,26, maxColorValue=255),
    rgb(37,122,164, maxColorValue=255),
    rgb(78,155,133, maxColorValue=255),
    rgb(86,51,94, maxColorValue=255)
  ))

p6b <- ggplot(data_ext_pdag_er_avg_m4, aes(x=file, y=mean, group=Algorithm, color=Algorithm)) +
  geom_line(aes(group=Algorithm, linetype=Algorithm, color=Algorithm)) +
  geom_point(aes(shape=Algorithm, color=Algorithm)) +
  ggtitle("$m = \\sqrt n \\cdot n$") +
  xlab("$n$") +
  ylab("time (ms)") +
  theme_classic() +
  theme(
    axis.line.x = element_line(arrow = grid::arrow(length = unit(0.1, "cm"))),
    axis.line.y = element_line(arrow = grid::arrow(length = unit(0.1, "cm")))
  ) +
  scale_x_discrete(labels = function(x) gsub('[a-z]{4,7}-0{0,3}(\\d{1,4})-.*', '\\1', x)) +
  scale_color_manual(values=c(
    rgb(247,192,26, maxColorValue=255),
    rgb(37,122,164, maxColorValue=255),
    rgb(78,155,133, maxColorValue=255),
    rgb(86,51,94, maxColorValue=255)
  ))

#pdf(file = "results-ext-pdag-er.pdf", height = 4.8)
tikz('results-ext-pdag-er.tex', standAlone = FALSE, height = 4.8)
p5 + p5b + p6 + p6b +
  plot_layout(ncol = 2, nrow = 2, guides = "collect") &
  theme(
    legend.position = "bottom",
    plot.title = element_text(size=11),
    axis.text = element_text(size=11)
  )
dev.off()

p7 <- ggplot(data_mo_pdag_ba_avg_m1, aes(x=file, y=mean, group=Algorithm, color=Algorithm)) +
  geom_line(aes(group=Algorithm, linetype=Algorithm, color=Algorithm)) +
  geom_point(aes(shape=Algorithm, color=Algorithm)) +
  ggtitle("$m = 3 \\cdot n$") +
  xlab("$n$") +
  ylab("time (ms)") +
  theme_classic() +
  theme(
    axis.line.x = element_line(arrow = grid::arrow(length = unit(0.1, "cm"))),
    axis.line.y = element_line(arrow = grid::arrow(length = unit(0.1, "cm")))
  ) +
  scale_x_discrete(labels = function(x) gsub('[a-z]{4,7}-0{0,3}(\\d{1,4})-.*', '\\1', x)) +
  scale_color_manual(values=c(
    rgb(247,192,26, maxColorValue=255),
    rgb(37,122,164, maxColorValue=255),
    rgb(78,155,133, maxColorValue=255),
    rgb(86,51,94, maxColorValue=255)
  ))

p8 <- ggplot(data_mo_pdag_ba_avg_m2, aes(x=file, y=mean, group=Algorithm, color=Algorithm)) +
  geom_line(aes(group=Algorithm, linetype=Algorithm, color=Algorithm)) +
  geom_point(aes(shape=Algorithm, color=Algorithm)) +
  ggtitle("$m = \\log_2(n) \\cdot n$") +
  xlab("$n$") +
  ylab("time (ms)") +
  theme_classic() +
  theme(
    axis.line.x = element_line(arrow = grid::arrow(length = unit(0.1, "cm"))),
    axis.line.y = element_line(arrow = grid::arrow(length = unit(0.1, "cm")))
  ) +
  scale_x_discrete(labels = function(x) gsub('[a-z]{4,7}-0{0,3}(\\d{1,4})-.*', '\\1', x)) +
  scale_color_manual(values=c(
    rgb(247,192,26, maxColorValue=255),
    rgb(37,122,164, maxColorValue=255),
    rgb(78,155,133, maxColorValue=255),
    rgb(86,51,94, maxColorValue=255)
  ))

p7b <- ggplot(data_mo_pdag_ba_avg_m3, aes(x=file, y=mean, group=Algorithm, color=Algorithm)) +
  geom_line(aes(group=Algorithm, linetype=Algorithm, color=Algorithm)) +
  geom_point(aes(shape=Algorithm, color=Algorithm)) +
  ggtitle("$m = 5 \\cdot n$") +
  xlab("$n$") +
  ylab("time (ms)") +
  theme_classic() +
  theme(
    axis.line.x = element_line(arrow = grid::arrow(length = unit(0.1, "cm"))),
    axis.line.y = element_line(arrow = grid::arrow(length = unit(0.1, "cm")))
  ) +
  scale_x_discrete(labels = function(x) gsub('[a-z]{4,7}-0{0,3}(\\d{1,4})-.*', '\\1', x)) +
  scale_color_manual(values=c(
    rgb(247,192,26, maxColorValue=255),
    rgb(37,122,164, maxColorValue=255),
    rgb(78,155,133, maxColorValue=255),
    rgb(86,51,94, maxColorValue=255)
  ))

p8b <- ggplot(data_mo_pdag_ba_avg_m4, aes(x=file, y=mean, group=Algorithm, color=Algorithm)) +
  geom_line(aes(group=Algorithm, linetype=Algorithm, color=Algorithm)) +
  geom_point(aes(shape=Algorithm, color=Algorithm)) +
  ggtitle("$m = \\sqrt n \\cdot n$") +
  xlab("$n$") +
  ylab("time (ms)") +
  theme_classic() +
  theme(
    axis.line.x = element_line(arrow = grid::arrow(length = unit(0.1, "cm"))),
    axis.line.y = element_line(arrow = grid::arrow(length = unit(0.1, "cm")))
  ) +
  scale_x_discrete(labels = function(x) gsub('[a-z]{4,7}-0{0,3}(\\d{1,4})-.*', '\\1', x)) +
  scale_color_manual(values=c(
    rgb(247,192,26, maxColorValue=255),
    rgb(37,122,164, maxColorValue=255),
    rgb(78,155,133, maxColorValue=255),
    rgb(86,51,94, maxColorValue=255)
  ))

#pdf(file = "results-mo-pdag-ba.pdf", height = 4.8)
tikz('results-mo-pdag-ba.tex', standAlone = FALSE, height = 4.8)
p7 + p7b + p8 + p8b +
  plot_layout(ncol = 2, nrow = 2, guides = "collect") &
  theme(
    legend.position = "bottom",
    plot.title = element_text(size=11),
    axis.text = element_text(size=11)
  )
dev.off()

p9 <- ggplot(data_mo_pdag_er_avg_m1, aes(x=file, y=mean, group=Algorithm, color=Algorithm)) +
  geom_line(aes(group=Algorithm, linetype=Algorithm, color=Algorithm)) +
  geom_point(aes(shape=Algorithm, color=Algorithm)) +
  ggtitle("$m = 3 \\cdot n$") +
  xlab("$n$") +
  ylab("time (ms)") +
  theme_classic() +
  theme(
    axis.line.x = element_line(arrow = grid::arrow(length = unit(0.1, "cm"))),
    axis.line.y = element_line(arrow = grid::arrow(length = unit(0.1, "cm")))
  ) +
  scale_x_discrete(labels = function(x) gsub('[a-z]{4,7}-0{0,3}(\\d{1,4})-.*', '\\1', x)) +
  scale_color_manual(values=c(
    rgb(247,192,26, maxColorValue=255),
    rgb(37,122,164, maxColorValue=255),
    rgb(78,155,133, maxColorValue=255),
    rgb(86,51,94, maxColorValue=255)
  ))

p10 <- ggplot(data_mo_pdag_er_avg_m2, aes(x=file, y=mean, group=Algorithm, color=Algorithm)) +
  geom_line(aes(group=Algorithm, linetype=Algorithm, color=Algorithm)) +
  geom_point(aes(shape=Algorithm, color=Algorithm)) +
  ggtitle("$m = \\log_2(n) \\cdot n$") +
  xlab("$n$") +
  ylab("time (ms)") +
  theme_classic() +
  theme(
    axis.line.x = element_line(arrow = grid::arrow(length = unit(0.1, "cm"))),
    axis.line.y = element_line(arrow = grid::arrow(length = unit(0.1, "cm")))
  ) +
  scale_x_discrete(labels = function(x) gsub('[a-z]{4,7}-0{0,3}(\\d{1,4})-.*', '\\1', x)) +
  scale_color_manual(values=c(
    rgb(247,192,26, maxColorValue=255),
    rgb(37,122,164, maxColorValue=255),
    rgb(78,155,133, maxColorValue=255),
    rgb(86,51,94, maxColorValue=255)
  ))

p9b <- ggplot(data_mo_pdag_er_avg_m3, aes(x=file, y=mean, group=Algorithm, color=Algorithm)) +
  geom_line(aes(group=Algorithm, linetype=Algorithm, color=Algorithm)) +
  geom_point(aes(shape=Algorithm, color=Algorithm)) +
  ggtitle("$m = 5 \\cdot n$") +
  xlab("$n$") +
  ylab("time (ms)") +
  theme_classic() +
  theme(
    axis.line.x = element_line(arrow = grid::arrow(length = unit(0.1, "cm"))),
    axis.line.y = element_line(arrow = grid::arrow(length = unit(0.1, "cm")))
  ) +
  scale_x_discrete(labels = function(x) gsub('[a-z]{4,7}-0{0,3}(\\d{1,4})-.*', '\\1', x)) +
  scale_color_manual(values=c(
    rgb(247,192,26, maxColorValue=255),
    rgb(37,122,164, maxColorValue=255),
    rgb(78,155,133, maxColorValue=255),
    rgb(86,51,94, maxColorValue=255)
  ))

p10b <- ggplot(data_mo_pdag_er_avg_m4, aes(x=file, y=mean, group=Algorithm, color=Algorithm)) +
  geom_line(aes(group=Algorithm, linetype=Algorithm, color=Algorithm)) +
  geom_point(aes(shape=Algorithm, color=Algorithm)) +
  ggtitle("$m = \\sqrt n \\cdot n$") +
  xlab("$n$") +
  ylab("time (ms)") +
  theme_classic() +
  theme(
    axis.line.x = element_line(arrow = grid::arrow(length = unit(0.1, "cm"))),
    axis.line.y = element_line(arrow = grid::arrow(length = unit(0.1, "cm")))
  ) +
  scale_x_discrete(labels = function(x) gsub('[a-z]{4,7}-0{0,3}(\\d{1,4})-.*', '\\1', x)) +
  scale_color_manual(values=c(
    rgb(247,192,26, maxColorValue=255),
    rgb(37,122,164, maxColorValue=255),
    rgb(78,155,133, maxColorValue=255),
    rgb(86,51,94, maxColorValue=255)
  ))

#pdf(file = "results-mo-pdag-er.pdf", height = 2.4)
tikz('results-mo-pdag-er.tex', standAlone = FALSE, height = 2.4)
p9 + p10b +
  plot_layout(ncol = 2, guides = "collect") &
  theme(
    legend.position = "bottom",
    plot.title = element_text(size=11),
    axis.text = element_text(size=11)
  )
dev.off()

#pdf(file = "results-mo-pdag-er-more-m.pdf", height = 2.4)
tikz('results-mo-pdag-er-more-m.tex', standAlone = FALSE, height = 2.4)
p9b + p10 +
  plot_layout(ncol = 2, guides = "collect") &
  theme(
    legend.position = "bottom",
    plot.title = element_text(size=11),
    axis.text = element_text(size=11)
  )
dev.off()

# p11 <- ggplot(data_ext_cpdag_ba_avg_m1, aes(x=file, y=mean, group=Algorithm, color=Algorithm)) +
#   geom_line(aes(group=Algorithm, linetype=Algorithm, color=Algorithm)) +
#   geom_point(aes(shape=Algorithm, color=Algorithm)) +
#   ggtitle("$k = 3$") +
#   xlab("$n$") +
#   ylab("time (ms)") +
#   theme_classic() +
#   theme(
#     axis.line.x = element_line(arrow = grid::arrow(length = unit(0.1, "cm"))),
#     axis.line.y = element_line(arrow = grid::arrow(length = unit(0.1, "cm")))
#   ) +
#   scale_x_discrete(labels = function(x) gsub('[a-z]{4,7}-0{0,3}(\\d{1,4})-.*', '\\1', x)) +
#   scale_color_manual(values=c(
#     rgb(78,155,133, maxColorValue=255),
#     rgb(86,51,94, maxColorValue=255),
#     rgb(247,192,26, maxColorValue=255),
#     rgb(37,122,164, maxColorValue=255)
#   ))

# p12 <- ggplot(data_ext_cpdag_ba_avg_m2, aes(x=file, y=mean, group=Algorithm, color=Algorithm)) +
#   geom_line(aes(group=Algorithm, linetype=Algorithm, color=Algorithm)) +
#   geom_point(aes(shape=Algorithm, color=Algorithm)) +
#   ggtitle("$k = \\log_2(n)$") +
#   xlab("$n$") +
#   ylab("time (ms)") +
#   theme_classic() +
#   theme(
#     axis.line.x = element_line(arrow = grid::arrow(length = unit(0.1, "cm"))),
#     axis.line.y = element_line(arrow = grid::arrow(length = unit(0.1, "cm")))
#   ) +
#   scale_x_discrete(labels = function(x) gsub('[a-z]{4,7}-0{0,3}(\\d{1,4})-.*', '\\1', x)) +
#   scale_color_manual(values=c(
#     rgb(78,155,133, maxColorValue=255),
#     rgb(86,51,94, maxColorValue=255),
#     rgb(247,192,26, maxColorValue=255),
#     rgb(37,122,164, maxColorValue=255)
#   ))

# #pdf(file = "results-ext-cpdag-ba.pdf", height = 2.4)
# tikz('results-ext-cpdag-ba.tex', standAlone = FALSE, height = 2.4)
# p11 + p12 +
#   plot_layout(ncol = 2, guides = "collect") &
#   theme(
#     legend.position = "bottom",
#     plot.title = element_text(size=11),
#     axis.text = element_text(size=11)
#   )
# dev.off()

# p13 <- ggplot(data_ext_cpdag_er_avg_m1, aes(x=file, y=mean, group=Algorithm, color=Algorithm)) +
#   geom_line(aes(group=Algorithm, linetype=Algorithm, color=Algorithm)) +
#   geom_point(aes(shape=Algorithm, color=Algorithm)) +
#   ggtitle("$k = 3$") +
#   xlab("$n$") +
#   ylab("time (ms)") +
#   theme_classic() +
#   theme(
#     axis.line.x = element_line(arrow = grid::arrow(length = unit(0.1, "cm"))),
#     axis.line.y = element_line(arrow = grid::arrow(length = unit(0.1, "cm")))
#   ) +
#   scale_x_discrete(labels = function(x) gsub('[a-z]{4,7}-0{0,3}(\\d{1,4})-.*', '\\1', x)) +
#   scale_color_manual(values=c(
#     rgb(78,155,133, maxColorValue=255),
#     rgb(86,51,94, maxColorValue=255),
#     rgb(247,192,26, maxColorValue=255),
#     rgb(37,122,164, maxColorValue=255)
#   ))

# p14 <- ggplot(data_ext_cpdag_er_avg_m2, aes(x=file, y=mean, group=Algorithm, color=Algorithm)) +
#   geom_line(aes(group=Algorithm, linetype=Algorithm, color=Algorithm)) +
#   geom_point(aes(shape=Algorithm, color=Algorithm)) +
#   ggtitle("$k = \\log_2(n)$") +
#   xlab("$n$") +
#   ylab("time (ms)") +
#   theme_classic() +
#   theme(
#     axis.line.x = element_line(arrow = grid::arrow(length = unit(0.1, "cm"))),
#     axis.line.y = element_line(arrow = grid::arrow(length = unit(0.1, "cm")))
#   ) +
#   scale_x_discrete(labels = function(x) gsub('[a-z]{4,7}-0{0,3}(\\d{1,4})-.*', '\\1', x)) +
#   scale_color_manual(values=c(
#     rgb(78,155,133, maxColorValue=255),
#     rgb(86,51,94, maxColorValue=255),
#     rgb(247,192,26, maxColorValue=255),
#     rgb(37,122,164, maxColorValue=255)
#   ))

# #pdf(file = "results-ext-cpdag-er.pdf", height = 2.4)
# tikz('results-ext-cpdag-er.tex', standAlone = FALSE, height = 2.4)
# p13 + p14 +
#   plot_layout(ncol = 2, guides = "collect") &
#   theme(
#     legend.position = "bottom",
#     plot.title = element_text(size=11),
#     axis.text = element_text(size=11)
#   )
# dev.off()

# p15 <- ggplot(data_mo_cpdag_ba_avg_m1, aes(x=file, y=mean, group=Algorithm, color=Algorithm)) +
#   geom_line(aes(group=Algorithm, linetype=Algorithm, color=Algorithm)) +
#   geom_point(aes(shape=Algorithm, color=Algorithm)) +
#   ggtitle("$m = 3 \\cdot n$") +
#   xlab("$n$") +
#   ylab("time (ms)") +
#   theme_classic() +
#   theme(
#     axis.line.x = element_line(arrow = grid::arrow(length = unit(0.1, "cm"))),
#     axis.line.y = element_line(arrow = grid::arrow(length = unit(0.1, "cm")))
#   ) +
#   scale_x_discrete(labels = function(x) gsub('[a-z]{4,7}-0{0,3}(\\d{1,4})-.*', '\\1', x)) +
#   scale_color_manual(values=c(
#     rgb(78,155,133, maxColorValue=255),
#     rgb(86,51,94, maxColorValue=255),
#     rgb(247,192,26, maxColorValue=255),
#     rgb(37,122,164, maxColorValue=255)
#   ))

# p16 <- ggplot(data_mo_cpdag_ba_avg_m2, aes(x=file, y=mean, group=Algorithm, color=Algorithm)) +
#   geom_line(aes(group=Algorithm, linetype=Algorithm, color=Algorithm)) +
#   geom_point(aes(shape=Algorithm, color=Algorithm)) +
#   ggtitle("$m = \\log_2(n) \\cdot n$") +
#   xlab("$n$") +
#   ylab("time (ms)") +
#   theme_classic() +
#   theme(
#     axis.line.x = element_line(arrow = grid::arrow(length = unit(0.1, "cm"))),
#     axis.line.y = element_line(arrow = grid::arrow(length = unit(0.1, "cm")))
#   ) +
#   scale_x_discrete(labels = function(x) gsub('[a-z]{4,7}-0{0,3}(\\d{1,4})-.*', '\\1', x)) +
#   scale_color_manual(values=c(
#     rgb(78,155,133, maxColorValue=255),
#     rgb(86,51,94, maxColorValue=255),
#     rgb(247,192,26, maxColorValue=255),
#     rgb(37,122,164, maxColorValue=255)
#   ))

# #pdf(file = "results-mo-cpdag-ba.pdf", height = 2.4)
# tikz('results-mo-cpdag-ba.tex', standAlone = FALSE, height = 2.4)
# p15 + p16 +
#   plot_layout(ncol = 2, guides = "collect") &
#   theme(
#     legend.position = "bottom",
#     plot.title = element_text(size=11),
#     axis.text = element_text(size=11)
#   )
# dev.off()

# p17 <- ggplot(data_mo_cpdag_er_avg_m1, aes(x=file, y=mean, group=Algorithm, color=Algorithm)) +
#   geom_line(aes(group=Algorithm, linetype=Algorithm, color=Algorithm)) +
#   geom_point(aes(shape=Algorithm, color=Algorithm)) +
#   ggtitle("$m = 3 \\cdot n$") +
#   xlab("$n$") +
#   ylab("time (ms)") +
#   theme_classic() +
#   theme(
#     axis.line.x = element_line(arrow = grid::arrow(length = unit(0.1, "cm"))),
#     axis.line.y = element_line(arrow = grid::arrow(length = unit(0.1, "cm")))
#   ) +
#   scale_x_discrete(labels = function(x) gsub('[a-z]{4,7}-0{0,3}(\\d{1,4})-.*', '\\1', x)) +
#   scale_color_manual(values=c(
#     rgb(78,155,133, maxColorValue=255),
#     rgb(86,51,94, maxColorValue=255),
#     rgb(247,192,26, maxColorValue=255),
#     rgb(37,122,164, maxColorValue=255)
#   ))

# p18 <- ggplot(data_mo_cpdag_er_avg_m2, aes(x=file, y=mean, group=Algorithm, color=Algorithm)) +
#   geom_line(aes(group=Algorithm, linetype=Algorithm, color=Algorithm)) +
#   geom_point(aes(shape=Algorithm, color=Algorithm)) +
#   ggtitle("$m = \\log_2(n) \\cdot n$") +
#   xlab("$n$") +
#   ylab("time (ms)") +
#   theme_classic() +
#   theme(
#     axis.line.x = element_line(arrow = grid::arrow(length = unit(0.1, "cm"))),
#     axis.line.y = element_line(arrow = grid::arrow(length = unit(0.1, "cm")))
#   ) +
#   scale_x_discrete(labels = function(x) gsub('[a-z]{4,7}-0{0,3}(\\d{1,4})-.*', '\\1', x)) +
#   scale_color_manual(values=c(
#     rgb(78,155,133, maxColorValue=255),
#     rgb(86,51,94, maxColorValue=255),
#     rgb(247,192,26, maxColorValue=255),
#     rgb(37,122,164, maxColorValue=255)
#   ))

# #pdf(file = "results-mo-cpdag-er.pdf", height = 2.4)
# tikz('results-mo-cpdag-er.tex', standAlone = FALSE, height = 2.4)
# p17 + p18 +
#   plot_layout(ncol = 2, guides = "collect") &
#   theme(
#     legend.position = "bottom",
#     plot.title = element_text(size=11),
#     axis.text = element_text(size=11)
#   )
# dev.off()


data_mo_pdag_bar_1 = filter(data_mo_pdag_bar, type == "1")
data_mo_pdag_bar_2 = filter(data_mo_pdag_bar, type == "2")
data_mo_pdag_bar_3 = filter(data_mo_pdag_bar, type == "3")
data_mo_pdag_bar_t = filter(data_mo_pdag_bar, type == "total")

d1 = merge(x = data_mo_pdag_bar_1, y = data_mo_pdag_bar_t, by = "file", all = TRUE)
d2 = merge(x = data_mo_pdag_bar_2, y = data_mo_pdag_bar_t, by = "file", all = TRUE)
d3 = merge(x = data_mo_pdag_bar_3, y = data_mo_pdag_bar_t, by = "file", all = TRUE)
d1 = mutate(d1, mean_perc = mean.x / mean.y)
d2 = mutate(d2, mean_perc = mean.x / mean.y)
d3 = mutate(d3, mean_perc = mean.x / mean.y)
d_all = do.call("rbind", list(d1, d2, d3))
d_all = rename(d_all, "Phase" = "type.x")

d_all["Phase"][d_all["Phase"] == "1"] = "(i)"
d_all["Phase"][d_all["Phase"] == "2"] = "(ii)"
d_all["Phase"][d_all["Phase"] == "3"] = "(iii)"

data_mo_pdag_bar_ba_avg = filter(d_all, grepl("-ba-avg.gr", file, fixed = TRUE))
data_mo_pdag_bar_er_avg = filter(d_all, grepl("-er-avg.gr", file, fixed = TRUE))

data_mo_pdag_bar_ba_avg_m1 = filter(data_mo_pdag_bar_ba_avg, m.x == 3*n.x)
data_mo_pdag_bar_ba_avg_m2 = filter(data_mo_pdag_bar_ba_avg, m.x == round(log2(n.x), digits=0)*n.x)
data_mo_pdag_bar_ba_avg_m3 = filter(data_mo_pdag_bar_ba_avg, m.x == 5*n.x)
data_mo_pdag_bar_ba_avg_m4 = filter(data_mo_pdag_bar_ba_avg, m.x == round(sqrt(n.x), digits=0)*n.x)

data_mo_pdag_bar_er_avg_m1 = filter(data_mo_pdag_bar_er_avg, m.x == 3*n.x)
data_mo_pdag_bar_er_avg_m2 = filter(data_mo_pdag_bar_er_avg, m.x == round(log2(n.x), digits=0)*n.x)
data_mo_pdag_bar_er_avg_m3 = filter(data_mo_pdag_bar_er_avg, m.x == 5*n.x)
data_mo_pdag_bar_er_avg_m4 = filter(data_mo_pdag_bar_er_avg, m.x == round(sqrt(n.x), digits=0)*n.x)

p19 <- ggplot(data_mo_pdag_bar_ba_avg_m1, aes(x=file, y=mean_perc, fill=Phase)) +
  geom_bar(position="fill", stat="identity") +
  ggtitle("$m = 3 \\cdot n$") +
  xlab("$n$") +
  ylab("proportion of total time") +
  theme_classic() +
  theme(
    axis.line.x = element_line(arrow = grid::arrow(length = unit(0.1, "cm")))
  ) +
  scale_x_discrete(labels = function(x) gsub('[a-z]{4,7}-0{0,3}(\\d{1,4})-.*', '\\1', x)) +
  scale_fill_manual(values=c(
    rgb(247,192,26,120,maxColorValue=255),
    rgb(86,51,94,120,maxColorValue=255),
    rgb(78,155,133,120,maxColorValue=255)
  ))

p20 <- ggplot(data_mo_pdag_bar_ba_avg_m2, aes(x=file, y=mean_perc, fill=Phase)) +
  geom_bar(position="fill", stat="identity") +
  ggtitle("$m = \\log_2(n) \\cdot n$") +
  xlab("$n$") +
  ylab("proportion of total time") +
  theme_classic() +
  theme(
    axis.line.x = element_line(arrow = grid::arrow(length = unit(0.1, "cm")))
  ) +
  scale_x_discrete(labels = function(x) gsub('[a-z]{4,7}-0{0,3}(\\d{1,4})-.*', '\\1', x)) +
  scale_fill_manual(values=c(
    rgb(247,192,26,120,maxColorValue=255),
    rgb(86,51,94,120,maxColorValue=255),
    rgb(78,155,133,120,maxColorValue=255)
  ))

p19b <- ggplot(data_mo_pdag_bar_ba_avg_m3, aes(x=file, y=mean_perc, fill=Phase)) +
  geom_bar(position="fill", stat="identity") +
  ggtitle("$m = 5 \\cdot n$") +
  xlab("$n$") +
  ylab("proportion of total time") +
  theme_classic() +
  theme(
    axis.line.x = element_line(arrow = grid::arrow(length = unit(0.1, "cm")))
  ) +
  scale_x_discrete(labels = function(x) gsub('[a-z]{4,7}-0{0,3}(\\d{1,4})-.*', '\\1', x)) +
  scale_fill_manual(values=c(
    rgb(247,192,26,120,maxColorValue=255),
    rgb(86,51,94,120,maxColorValue=255),
    rgb(78,155,133,120,maxColorValue=255)
  ))

p20b <- ggplot(data_mo_pdag_bar_ba_avg_m4, aes(x=file, y=mean_perc, fill=Phase)) +
  geom_bar(position="fill", stat="identity") +
  ggtitle("$m = \\sqrt n \\cdot n$") +
  xlab("$n$") +
  ylab("proportion of total time") +
  theme_classic() +
  theme(
    axis.line.x = element_line(arrow = grid::arrow(length = unit(0.1, "cm")))
  ) +
  scale_x_discrete(labels = function(x) gsub('[a-z]{4,7}-0{0,3}(\\d{1,4})-.*', '\\1', x)) +
  scale_fill_manual(values=c(
    rgb(247,192,26,120,maxColorValue=255),
    rgb(86,51,94,120,maxColorValue=255),
    rgb(78,155,133,120,maxColorValue=255)
  ))

#pdf(file = "results-mo-perc-pdag-ba.pdf", height = 4.8)
tikz('results-mo-perc-pdag-ba.tex', standAlone = FALSE, height = 4.8)
p19 + p19b + p20 + p20b +
  plot_layout(ncol = 2, nrow = 2, guides = "collect") &
  theme(
    legend.position = "bottom",
    plot.title = element_text(size=11),
    axis.text = element_text(size=11)
  )
dev.off()

p21 <- ggplot(data_mo_pdag_bar_er_avg_m1, aes(x=file, y=mean_perc, fill=Phase)) +
  geom_bar(position="fill", stat="identity") +
  ggtitle("$m = 3 \\cdot n$") +
  xlab("$n$") +
  ylab("proportion of total time") +
  theme_classic() +
  theme(
    axis.line.x = element_line(arrow = grid::arrow(length = unit(0.1, "cm")))
  ) +
  scale_x_discrete(labels = function(x) gsub('[a-z]{4,7}-0{0,3}(\\d{1,4})-.*', '\\1', x)) +
  scale_fill_manual(values=c(
    rgb(247,192,26,120,maxColorValue=255),
    rgb(86,51,94,120,maxColorValue=255),
    rgb(78,155,133,120,maxColorValue=255)
  ))

p22 <- ggplot(data_mo_pdag_bar_er_avg_m2, aes(x=file, y=mean_perc, fill=Phase)) +
  geom_bar(position="fill", stat="identity") +
  ggtitle("$m = \\log_2(n) \\cdot n$") +
  xlab("$n$") +
  ylab("proportion of total time") +
  theme_classic() +
  theme(
    axis.line.x = element_line(arrow = grid::arrow(length = unit(0.1, "cm")))
  ) +
  scale_x_discrete(labels = function(x) gsub('[a-z]{4,7}-0{0,3}(\\d{1,4})-.*', '\\1', x)) +
  scale_fill_manual(values=c(
    rgb(247,192,26,120,maxColorValue=255),
    rgb(86,51,94,120,maxColorValue=255),
    rgb(78,155,133,120,maxColorValue=255)
  ))

p21b <- ggplot(data_mo_pdag_bar_er_avg_m3, aes(x=file, y=mean_perc, fill=Phase)) +
  geom_bar(position="fill", stat="identity") +
  ggtitle("$m = 5 \\cdot n$") +
  xlab("$n$") +
  ylab("proportion of total time") +
  theme_classic() +
  theme(
    axis.line.x = element_line(arrow = grid::arrow(length = unit(0.1, "cm")))
  ) +
  scale_x_discrete(labels = function(x) gsub('[a-z]{4,7}-0{0,3}(\\d{1,4})-.*', '\\1', x)) +
  scale_fill_manual(values=c(
    rgb(247,192,26,120,maxColorValue=255),
    rgb(86,51,94,120,maxColorValue=255),
    rgb(78,155,133,120,maxColorValue=255)
  ))

p22b <- ggplot(data_mo_pdag_bar_er_avg_m4, aes(x=file, y=mean_perc, fill=Phase)) +
  geom_bar(position="fill", stat="identity") +
  ggtitle("$m = \\sqrt n \\cdot n$") +
  xlab("$n$") +
  ylab("proportion of total time") +
  theme_classic() +
  theme(
    axis.line.x = element_line(arrow = grid::arrow(length = unit(0.1, "cm")))
  ) +
  scale_x_discrete(labels = function(x) gsub('[a-z]{4,7}-0{0,3}(\\d{1,4})-.*', '\\1', x)) +
  scale_fill_manual(values=c(
    rgb(247,192,26,120,maxColorValue=255),
    rgb(86,51,94,120,maxColorValue=255),
    rgb(78,155,133,120,maxColorValue=255)
  ))

#pdf(file = "results-mo-perc-pdag-er.pdf", height = 2.4)
tikz('results-mo-perc-pdag-er.tex', standAlone = FALSE, height = 2.4)
p21 + p22b +
  plot_layout(ncol = 2, guides = "collect") &
  theme(
    legend.position = "bottom",
    plot.title = element_text(size=11),
    axis.text = element_text(size=11)
  )
dev.off()

#pdf(file = "results-mo-perc-pdag-er-more-m.pdf", height = 2.4)
tikz('results-mo-perc-pdag-er-more-m.tex', standAlone = FALSE, height = 2.4)
p21b + p22 +
  plot_layout(ncol = 2, guides = "collect") &
  theme(
    legend.position = "bottom",
    plot.title = element_text(size=11),
    axis.text = element_text(size=11)
  )
dev.off()
