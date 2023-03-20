library(ggplot2)
library(dplyr)
library(patchwork)
library(stringr)
library(tikzDevice)

d_pdag    = read.csv(file = "results-ext-pdag.csv", sep=",", dec=".")
d_pdag_ll = read.csv(file = "results-ext-pdag-ll.csv", sep=",", dec=".")

d_pdag["algo"][d_pdag["algo"] == "pdag2dag_dt"]   = "\\textsc{dt}"
d_pdag["algo"][d_pdag["algo"] == "pdag2dag_dtch"] = "\\textsc{dtic}"
d_pdag["algo"][d_pdag["algo"] == "pdag2dag_dth"]  = "\\textsc{dth}"
d_pdag["algo"][d_pdag["algo"] == "pdag2dag_wbl"]  = "\\textsc{wbl}"

d_pdag_ll["algo"][d_pdag_ll["algo"] == "pdag2dag_dt_ll"]   = "\\textsc{dt-ll}"
d_pdag_ll["algo"][d_pdag_ll["algo"] == "pdag2dag_dtch_ll"] = "\\textsc{dtic-ll}"
d_pdag_ll["algo"][d_pdag_ll["algo"] == "pdag2dag_dth_ll"]  = "\\textsc{dth-ll}"
d_pdag_ll["algo"][d_pdag_ll["algo"] == "pdag2dag_wbl_ll"]  = "\\textsc{wbl-ll}"

d_pdag    = rename(d_pdag, "Algorithm" = "algo")
d_pdag_ll = rename(d_pdag_ll, "Algorithm" = "algo")

d_pdag_ba_avg    = filter(d_pdag, grepl("-ba-avg.gr", file, fixed = TRUE))
d_pdag_er_avg    = filter(d_pdag, grepl("-er-avg.gr", file, fixed = TRUE))
d_pdag_ll_ba_avg = filter(d_pdag_ll, grepl("-ba-avg.gr", file, fixed = TRUE))
d_pdag_ll_er_avg = filter(d_pdag_ll, grepl("-er-avg.gr", file, fixed = TRUE))

d_pdag_ba_avg_m1    = filter(d_pdag_ba_avg, m == 3*n)
d_pdag_ba_avg_m2    = filter(d_pdag_ba_avg, m == round(log2(n), digits=0)*n)
d_pdag_er_avg_m1    = filter(d_pdag_er_avg, m == 3*n)
d_pdag_er_avg_m2    = filter(d_pdag_er_avg, m == round(log2(n), digits=0)*n)
d_pdag_ll_ba_avg_m1 = filter(d_pdag_ll_ba_avg, m == 3*n)
d_pdag_ll_ba_avg_m2 = filter(d_pdag_ll_ba_avg, m == round(log2(n), digits=0)*n)
d_pdag_ll_er_avg_m1 = filter(d_pdag_ll_er_avg, m == 3*n)
d_pdag_ll_er_avg_m2 = filter(d_pdag_ll_er_avg, m == round(log2(n), digits=0)*n)

# p1 <- ggplot(d_pdag_ll_ba_avg_m1, aes(x=file, y=mean, group=Algorithm, color=Algorithm)) +
#   geom_line(aes(group=Algorithm, linetype=Algorithm, color=Algorithm)) +
#   geom_point(aes(shape=Algorithm, color=Algorithm)) +
#   ggtitle("$m = 3 \\cdot n$") +
#   xlab("$n$") +
#   ylab("time (ms)") +
#   theme_minimal() +
#   scale_x_discrete(labels = function(x) gsub('[a-z]{4,7}-0{0,3}(\\d{1,4})-.*', '\\1', x))

# p2 <- ggplot(d_pdag_ll_ba_avg_m2, aes(x=file, y=mean, group=Algorithm, color=Algorithm)) +
#   geom_line(aes(group=Algorithm, linetype=Algorithm, color=Algorithm)) +
#   geom_point(aes(shape=Algorithm, color=Algorithm)) +
#   ggtitle("$m = \\log_2(n) \\cdot n$") +
#   xlab("$n$") +
#   ylab("time (ms)") +
#   theme_minimal() +
#   scale_x_discrete(labels = function(x) gsub('[a-z]{4,7}-0{0,3}(\\d{1,4})-.*', '\\1', x))

# pdf(file = "results-ext-pdag-ba-ll.pdf", height = 2.4)
# #tikz('results-ext-pdag-ba-ll.tex', standAlone = FALSE, height = 2.4)
# p1 + p2 +
#   plot_layout(ncol = 2, guides = "collect") &
#   theme(
#     legend.position = "bottom",
#     plot.title = element_text(size=11),
#     axis.text = element_text(size=11)
#   )
# dev.off()

# p3 <- ggplot(d_pdag_ll_er_avg_m1, aes(x=file, y=mean, group=Algorithm, color=Algorithm)) +
#   geom_line(aes(group=Algorithm, linetype=Algorithm, color=Algorithm)) +
#   geom_point(aes(shape=Algorithm, color=Algorithm)) +
#   ggtitle("$m = 3 \\cdot n$") +
#   xlab("$n$") +
#   ylab("time (ms)") +
#   theme_minimal() +
#   scale_x_discrete(labels = function(x) gsub('[a-z]{4,7}-0{0,3}(\\d{1,4})-.*', '\\1', x))

# p4 <- ggplot(d_pdag_ll_er_avg_m2, aes(x=file, y=mean, group=Algorithm, color=Algorithm)) +
#   geom_line(aes(group=Algorithm, linetype=Algorithm, color=Algorithm)) +
#   geom_point(aes(shape=Algorithm, color=Algorithm)) +
#   ggtitle("$m = \\log_2(n) \\cdot n$") +
#   xlab("$n$") +
#   ylab("time (ms)") +
#   theme_minimal() +
#   scale_x_discrete(labels = function(x) gsub('[a-z]{4,7}-0{0,3}(\\d{1,4})-.*', '\\1', x))

# pdf(file = "results-ext-pdag-er-ll.pdf", height = 2.4)
# #tikz('results-ext-pdag-er-ll.tex', standAlone = FALSE, height = 2.4)
# p3 + p4 +
#   plot_layout(ncol = 2, guides = "collect") &
#   theme(
#     legend.position = "bottom",
#     plot.title = element_text(size=11),
#     axis.text = element_text(size=11)
#   )
# dev.off()



d_chord    = read.csv(file = "results-ext-chordal.csv", sep=",", dec=".")
d_chord_ll = read.csv(file = "results-ext-chordal-ll.csv", sep=",", dec=".")

d_chord["algo"][d_chord["algo"] == "pdag2dag_dt"]   = "\\textsc{dt}"
d_chord["algo"][d_chord["algo"] == "pdag2dag_dtch"] = "\\textsc{dtic}"
d_chord["algo"][d_chord["algo"] == "pdag2dag_dth"]  = "\\textsc{dth}"
d_chord["algo"][d_chord["algo"] == "pdag2dag_wbl"]  = "\\textsc{wbl}"

d_chord_ll["algo"][d_chord_ll["algo"] == "pdag2dag_dt_ll"]   = "\\textsc{dt-ll}"
d_chord_ll["algo"][d_chord_ll["algo"] == "pdag2dag_dtch_ll"] = "\\textsc{dtic-ll}"
d_chord_ll["algo"][d_chord_ll["algo"] == "pdag2dag_dth_ll"]  = "\\textsc{dth-ll}"
d_chord_ll["algo"][d_chord_ll["algo"] == "pdag2dag_wbl_ll"]  = "\\textsc{wbl-ll}"

d_chord    = rename(d_chord, "Algorithm" = "algo")
d_chord_ll = rename(d_chord_ll, "Algorithm" = "algo")

d_chord_avg    = filter(d_chord, grepl("-avg.gr", file, fixed = TRUE))
d_chord_ll_avg = filter(d_chord_ll, grepl("-avg.gr", file, fixed = TRUE))

d_chord_avg_m1 = filter(
  d_chord_avg,
  grepl("chordal-\\d{1,4}-03-avg\\.gr", file)
)
d_chord_avg_m2 = filter(
  d_chord_avg,
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
d_chord_ll_avg_m1 = filter(
  d_chord_ll,
  grepl("chordal-\\d{1,4}-03-avg\\.gr", file)
)
d_chord_ll_avg_m2 = filter(
  d_chord_ll,
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

# p5 <- ggplot(d_chord_ll_avg_m1, aes(x=file, y=mean, group=Algorithm, color=Algorithm)) +
#   geom_line(aes(group=Algorithm, linetype=Algorithm, color=Algorithm)) +
#   geom_point(aes(shape=Algorithm, color=Algorithm)) +
#   ggtitle("$k = 3$") +
#   xlab("$n$") +
#   ylab("time (ms)") +
#   theme_minimal() +
#   scale_y_log10() +
#   scale_x_discrete(labels = function(x) gsub('[a-z]{4,7}-0{0,3}(\\d{1,4})-.*', '\\1', x))

# p6 <- ggplot(d_chord_ll_avg_m2, aes(x=file, y=mean, group=Algorithm, color=Algorithm)) +
#   geom_line(aes(group=Algorithm, linetype=Algorithm, color=Algorithm)) +
#   geom_point(aes(shape=Algorithm, color=Algorithm)) +
#   ggtitle("$k = \\log_2(n)$") +
#   xlab("$n$") +
#   ylab("time (ms)") +
#   theme_minimal() +
#   scale_y_log10() +
#   scale_x_discrete(labels = function(x) gsub('[a-z]{4,7}-0{0,3}(\\d{1,4})-.*', '\\1', x))

# pdf(file = "results-ext-chordal-ll.pdf", height = 2.4)
# #tikz('results-ext-chordal-ll.tex', standAlone = FALSE, height = 2.4)
# p5 + p6 +
#   plot_layout(ncol = 2, guides = "collect") &
#   theme(
#     legend.position = "bottom",
#     plot.title = element_text(size=11),
#     axis.text = element_text(size=11)
#   )
# dev.off()


d_pdag_all = do.call("rbind", list(d_pdag, d_pdag_ll))
#d_pdag_all = filter(d_pdag_all, grepl("wbl", Algorithm, fixed = TRUE))
d_pdag_all_ba = filter(d_pdag_all, grepl("-ba-avg.gr", file, fixed = TRUE))
d_pdag_all_er = filter(d_pdag_all, grepl("-er-avg.gr", file, fixed = TRUE))

d_pdag_all_ba_avg_m1 = filter(d_pdag_all_ba, m == 3*n)
d_pdag_all_ba_avg_m2 = filter(d_pdag_all_ba, m == round(log2(n), digits=0)*n)
d_pdag_all_er_avg_m1 = filter(d_pdag_all_er, m == 3*n)
d_pdag_all_er_avg_m2 = filter(d_pdag_all_er, m == round(log2(n), digits=0)*n)

p7 <- ggplot(d_pdag_all_ba_avg_m1, aes(x=file, y=mean, group=Algorithm, color=Algorithm)) +
  geom_line(aes(group=Algorithm, linetype=Algorithm, color=Algorithm)) +
  geom_point(aes(shape=Algorithm, color=Algorithm)) +
  ggtitle("$m = 3 \\cdot n$") +
  xlab("$n$") +
  ylab("time (ms)") +
  theme_minimal() +
  scale_x_discrete(labels = function(x) gsub('[a-z]{4,7}-0{0,3}(\\d{1,4})-.*', '\\1', x))

p8 <- ggplot(d_pdag_all_ba_avg_m2, aes(x=file, y=mean, group=Algorithm, color=Algorithm)) +
  geom_line(aes(group=Algorithm, linetype=Algorithm, color=Algorithm)) +
  geom_point(aes(shape=Algorithm, color=Algorithm)) +
  ggtitle("$m = \\log_2(n) \\cdot n$") +
  xlab("$n$") +
  ylab("time (ms)") +
  theme_minimal() +
  scale_x_discrete(labels = function(x) gsub('[a-z]{4,7}-0{0,3}(\\d{1,4})-.*', '\\1', x))

pdf(file = "results-ext-pdag-ba-comp.pdf", height = 2.4)
#tikz('results-ext-pdag-ba-comp.tex', standAlone = FALSE, height = 2.4)
p7 + p8 +
  plot_layout(ncol = 2, guides = "collect") &
  theme(
    legend.position = "bottom",
    plot.title = element_text(size=11),
    axis.text = element_text(size=11)
  )
dev.off()

p9 <- ggplot(d_pdag_all_er_avg_m1, aes(x=file, y=mean, group=Algorithm, color=Algorithm)) +
  geom_line(aes(group=Algorithm, linetype=Algorithm, color=Algorithm)) +
  geom_point(aes(shape=Algorithm, color=Algorithm)) +
  ggtitle("$m = 3 \\cdot n$") +
  xlab("$n$") +
  ylab("time (ms)") +
  theme_minimal() +
  scale_x_discrete(labels = function(x) gsub('[a-z]{4,7}-0{0,3}(\\d{1,4})-.*', '\\1', x))

p10 <- ggplot(d_pdag_all_er_avg_m2, aes(x=file, y=mean, group=Algorithm, color=Algorithm)) +
  geom_line(aes(group=Algorithm, linetype=Algorithm, color=Algorithm)) +
  geom_point(aes(shape=Algorithm, color=Algorithm)) +
  ggtitle("$m = \\log_2(n) \\cdot n$") +
  xlab("$n$") +
  ylab("time (ms)") +
  theme_minimal() +
  scale_x_discrete(labels = function(x) gsub('[a-z]{4,7}-0{0,3}(\\d{1,4})-.*', '\\1', x))

pdf(file = "results-ext-pdag-er-comp.pdf", height = 2.4)
#tikz('results-ext-pdag-er-comp.tex', standAlone = FALSE, height = 2.4)
p9 + p10 +
  plot_layout(ncol = 2, guides = "collect") &
  theme(
    legend.position = "bottom",
    plot.title = element_text(size=11),
    axis.text = element_text(size=11)
  )
dev.off()


d_chord_all = do.call("rbind", list(d_chord, d_chord_ll))
#d_chord_all = filter(d_chord_all, grepl("wbl", Algorithm, fixed = TRUE))
d_chord_all_avg = filter(d_chord_all, grepl("-avg.gr", file, fixed = TRUE))

d_chord_all_avg_m1 = filter(
  d_chord_all_avg,
  grepl("chordal-\\d{1,4}-03-avg\\.gr", file)
)
d_chord_all_avg_m2 = filter(
  d_chord_all_avg,
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

p11 <- ggplot(d_chord_all_avg_m1, aes(x=file, y=mean, group=Algorithm, color=Algorithm)) +
  geom_line(aes(group=Algorithm, linetype=Algorithm, color=Algorithm)) +
  geom_point(aes(shape=Algorithm, color=Algorithm)) +
  ggtitle("$m = 3 \\cdot n$") +
  xlab("$n$") +
  ylab("time (ms)") +
  theme_minimal() +
  scale_y_log10() +
  scale_x_discrete(labels = function(x) gsub('[a-z]{4,7}-0{0,3}(\\d{1,4})-.*', '\\1', x))

p12 <- ggplot(d_chord_all_avg_m2, aes(x=file, y=mean, group=Algorithm, color=Algorithm)) +
  geom_line(aes(group=Algorithm, linetype=Algorithm, color=Algorithm)) +
  geom_point(aes(shape=Algorithm, color=Algorithm)) +
  ggtitle("$m = \\log_2(n) \\cdot n$") +
  xlab("$n$") +
  ylab("time (ms)") +
  theme_minimal() +
  scale_y_log10() +
  scale_x_discrete(labels = function(x) gsub('[a-z]{4,7}-0{0,3}(\\d{1,4})-.*', '\\1', x))

pdf(file = "results-ext-chordal-comp.pdf", height = 2.4)
#tikz('results-ext-chordal-comp.tex', standAlone = FALSE, height = 2.4)
p11 + p12 +
  plot_layout(ncol = 2, guides = "collect") &
  theme(
    legend.position = "bottom",
    plot.title = element_text(size=11),
    axis.text = element_text(size=11)
  )
dev.off()
