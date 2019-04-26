
library(padr)
library(tidyverse)

setwd("C:/Users/daniel/Desktop/locstore/projects/porkBelly/investigations/food_tracker")

basics <- read_delim("foodTracker2018.tsv", "\t",
                     escape_double = FALSE, 
                     col_types = cols(Date = col_date(format = "%d/%m/%Y")), 
                     trim_ws = TRUE)




# compute distinct combinations per visit
grps <-basics %>% group_by(Date) %>% 
  distinct_at(.,vars(Item)) %>% 
  do(data.frame((t(combn(.$Item,2)))))

# get counts of unique combinations
cnts_pairs <- grps %>% group_by(X1,X2) %>% 
  summarise(counts=n()) 

# filter by most occurences with manual threshold
cnts_ind_reps <- grps %>% group_by(X1) %>% 
  summarise(counts_inds = n()) %>% 
  filter(counts_inds>=4)

# filter by quantile accouning for 50% of data
cnts_ind_quant <- grps %>% group_by(X1) %>% 
  summarise(counts_inds = n()) %>% 
  filter(counts_inds > quantile(counts_inds,0.50))

# join for different approaches
join_reps <- left_join(cnts_ind_reps,cnts_pairs)
join_quant <- left_join(cnts_ind_quant,cnts_pairs)


library(igraph)

food <- join_quant %>% 
  select(X1,X2)

food.mat <- as.matrix(food)

# an edge attribute
edge.att <- join_quant %>% 
  select(counts) %>% as.matrix()


# building an igraph object from an edgelist
g <- graph.edgelist(food.mat,directed=FALSE)

plot(g)

gsize(g)
gorder(g)

# setting edge properties
g <- set_edge_attr(g, "baskets", value = edge.att)

# items bought frequently together
unique(basics$Date)

E(g)[[baskets>=4]] 

# bought at same time as papaya
E(g)[[inc("Papaya")]]

## building a graph from a dataframe
## uses edges and vertices 
cnts_ind <- grps %>% group_by(X1) %>% 
  summarise(counts_inds = n())

# create food vertices
food_vertices <- basics %>% group_by(Item,Category) %>% 
  summarise(avg_price=round(mean(Price),1)) %>% 
  rename(food_type=Category)

# create food edges
food_edges <- left_join(cnts_ind,cnts_pairs) %>% 
  select(X1,X2,counts)

# build graph
g1 <- graph_from_data_frame(d=food_edges,vertices = food_vertices,
                            directed=FALSE)

plot(g1, vertex.size=0, vertex.label.color="black",
     edge.color="gray77")

# investigating vertices
V(g1)[[avg_price>=2.1]]

# count of categories
unique(vertex_attr(g1)$food_type)

# investigating edge properties
E(g1)[[inc("Eier")]]
E(g1)[[counts>=5]]


# customising graph
plot(g1, vertex.label.color = "black", layout = layout_with_fr(g1))
plot(g1, vertex.label.color = "black", layout = layout_as_tree(g1))
plot(g1, vertex.label.color = "black", layout = layout_nicely(g1))

g_counts <- delete_edges(g1, E(g1)[[counts < 3]])
g_prices <- delete_edges(g1, V(g1)[[avg_price >= 0.5]])

plot(g_counts, vertex.label.color = "black", layout = layout_with_fr(g_counts))
plot(g_prices, vertex.label.color = "black", layout = layout_with_fr(g_prices))

# investigating properties of network

# direct relationships
g1['Tomaten', 'Eier']

# connected edges
incident(g1, 'Tomaten')

# neighbours
neighbors(g1, 'Grapefruit', mode = c('all'))

# instersections
n1 <- neighbors(g1, 'Fenchel')
n2 <- neighbors(g1, 'Butter')
intersection(n1, n2)

# farthest vertices
farthest_vertices(g1)
get_diameter(g1) 

# calculate geodesic distance
ego(g, 1, 'Parmesan', mode = c('out'))

# key vertices
g.outd <- degree(g1, mode = c("out"))
table(g.outd)
hist(g.outd, breaks = 30)
which.max(g.outd)

g.ec <- eigen_centrality(g1)
which.max(g.ec$vector)

gd <- edge_density(g1)
diameter(g1, directed = FALSE)

g.apl <- mean_distance(g1, directed = FALSE)
g.apl

g.bet<- betweenness(g1,directed=FALSE)


plot(g1, 
     vertex.label = NA,
     edge.color = 'black',
     vertex.size = sqrt(g.bet)+1,
     edge.arrow.size = 0.05,
     layout = layout_nicely(g1))


# Make an ego graph
g136 <- make_ego_graph(g1, diameter(g1), nodes = 'Tomaten', mode = c("all"))[[1]]
dists <- distances(g136, "Tomaten")
max(dists)

colors <- c("dodgerblue", "red", "orange")
V(g136)$color <- colors[dists+1]

plot(g136,vertex.label=g.outd,
     vertex.label.color = "white",
     vertex.label.cex = .6,
     edge.color = 'black',
     vertex.size = 7,
     edge.arrow.size = .05,
     main = "Geodesic Distances from Most Connected Item - Tomatoes"
)


g.tr <- transitivity(g1)
transitivity(g, vids='Milch', type = "local")

largest_cliques(g1)
clq <- max_cliques(g1)
table(unlist(lapply(clq, length)))


## assostivatiy
values <- as.numeric(factor(V(g1)$food_type))
assortativity(g1, values)

assortativity.degree(g1, directed = FALSE)

kc = fastgreedy.community(g)

g <- simplify(g1)
sizes(kc)
membership(kc)

plot(kc, g)# plot: items vs total cost

library(threejs)

graphjs(g,vertex.size=1)

# weekly quantities
weekly_summary <-basics %>% 
  thicken(interval = 'week') %>% 
  group_by(Date_week) %>% 
  summarise(items_tot=n(),costs_tot=sum(Price)) %>% 
  arrange(desc(Date_week))



weekly_summary %>% 
  ggplot(., aes(items_tot,costs_tot)) + 
  geom_point() + geom_smooth(method = "lm") +
  theme_plain(base_size = 11) +
  xlab("Items Purchased (per Week)") +
  ylab("Total Cost (€)")

# plot :: weekly costs TS
weekly_summary %>% 
  ggplot(., aes(Date_week,costs_tot)) + 
  geom_point() + geom_smooth(method = "lm") +
  theme_plain(base_size = 11) +
  xlab("Date") +
  ylab("Weekly Expenditure (Estimated)")


# aggregate split per category
aggregate_costs <-basics %>% thicken(interval = 'week') %>% 
  mutate(Category=factor(Category)) %>% 
  group_by(Category) %>% 
  summarise(cost_total=sum(Price)) %>% 
  mutate(cost_total_prop=round(cost_total/sum(cost_total)*100,0)) %>% 
  arrange(desc(cost_total_prop))


  
# building model
model_data<-basics %>% thicken(interval = 'week') %>% 
  mutate(Category=factor(Category)) %>% 
  group_by(Date_week,Category) %>% 
  mutate(un = n()) %>% 
  summarise(cost_category=sum(Price),no_items=n()) %>% 
  mutate(cost_prop=round(cost_category/sum(cost_category)*100,0),
         no_items_prop=round(no_items/sum(no_items)*100,0))

# per item for OG
model_items <- basics %>% 
  mutate(Category=factor(Category),Item = factor(Item)) %>% 
  group_by(Category,Item) %>% 
  mutate(un = n()) %>% summarise(total_uses=n()) %>% 
  arrange(desc(total_uses)) %>% 
  filter(Category == "OG")

# plot :: cost vs yield by category
model_data %>% 
  ggplot(., aes(cost_prop,no_items_prop,colour=Category, size=no_items)) + 
  geom_point() + 
  theme_plain(base_size = 11) + 
  coord_trans(y="log",x="log") +
  scale_y_continuous(expand=c(0.1,0.1),
                     breaks=c(5,10,20,45)) +
  scale_x_continuous(expand=c(0.1,0.1),
                     breaks=c(5,10,20,45)) +
  xlab("Proportional Cost") +
  ylab("Proportional Amount") +
  labs(title="Relationship between Relative Spend and Yield over 9 Weeks (N = 52)",
       size="Items (n)") + 
  guides(color=guide_legend(title="Food Category")) 


# range of items per week
ggplot(model_data, aes(x=fct_reorder(Category,no_items_prop, fun = median, .desc=TRUE), y = no_items_prop)) +
  geom_boxplot(outlier.colour = "red",outlier.alpha = 0.75) +
  xlab("Category") + ylab("Quantity (%)") +
  theme_plain(base_size = 11) 


# exploring missing data
library(visdat)
library(naniar)
library(simputation)

vis_dat(basics)
vis_miss(basics)

miss_case_table(basics)

aq_shadow <- bind_shadow(basics)

ggplot(aq_shadow,
       aes(x = Price,
           colour = Weight_NA)) + 
  geom_density()


# proper imputation
str(basics)

basics_fct <- basics %>% mutate(Item_fct = as.factor(Item),
                                Category_fct = as.factor(Category)) %>% 
  select(-Item,-Category)

da1 <- impute_lm(basics_fct, Weight ~ Price | Item_fct)
head(da1,3)

da2 <- impute_median(basics_fct, Weight ~ Item_fct)
head(da2,3)

da8 <- impute_lm(basics_fct, Weight ~ Price | Item_fct)

da9 <- impute_lm(basics_fct, Weight ~ Price + Item_fct)

out <-basics_fct %>% impute_cart(Weight ~ Item_fct)


basics %>%
  impute_lm(Weight ~ Price ) %>%
  ggplot(aes(x = Price,
             y = Weight)) + 
  geom_point()




aq_shadow %>%
  impute_lm(Weight ~ Price) %>%
  ggplot(aes(x = Price,
             y = Weight,
             colour = Weight_NA)) + 
  geom_point()
  