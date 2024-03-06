#!/usr/bin/env python
# coding: utf-8

# In[1]:


# Importing Pandas
import pandas as pd


# In[2]:


# Reading in the data.
df = pd.read_csv('D:Muddasser\Programming Practise\cookie_cats.csv')


# In[3]:


# Showing the first few rows
df.head()


# In[4]:


# Data Preprocessing:

print("Number of Players: \n", df.userid.nunique(), '\n',
    "Number of Records: \n", len(df.userid), '\n')


# In[5]:


# Data Cleaning:
    
df.dtypes


# In[6]:


# Data Consistency:

# Function the plot to find the percentage of missing values.
def na_counter(df):
    print ("NAN Values per Column:")
    print ("")
    for i in df.columns:
        percentage = 100 - ((len(df[i]) - df[i].isna().sum())/len(df[i]))*100
        
        #only return columns with more than 5% of NA values
        if percentage > 5:
            print(i + "has " + str(round(percentage)) + "% of Null Values")
        else:
            continue
            
            
# Execute Function
na_counter(df)
                


# In[7]:


# By the reporting of none NAN Values more than 5%, it can be concluded that there were not errors in the telemetry logs during the data collection.


# In[8]:


# Normalization:

df.describe()

# Noticing the distribution of the quartiles and comprehending the purpose of our analysis, where we only require sum_gamrounds
# as numeric, we can validate that the data is comparable and doesn't need transformations.


# # Exploratory Analysis & In-Game Interpretations

# ## Summary Statistics

# In[9]:


# We got the next conclusions about their distribution and measurement:
# Userid
#   Interpretation: Player identifier with distinct records in the whole dataset which can be transformed as a factor.
#   Data Type: Nominal
#   Measurement Type: Discrete/String
# Version
#   Interpretation: Just two possible values to evaluate, time gate at level 30 or level 40.
#   Data Type: Ordinal
#   Measurement Type: Discrete/String
# Sum_gamerounds
#   Interpretation: Number of game rounds played by the user, where 50% of the users played between 5 and 51 sessions.
#   Data Type: Numerical
#   Measurement Type: Integer
# Retention_1
#   Interpretation: Boolean measure to verify that the player retention was effective for 1 day at least.
#   Data Type: Nominal
#   Measurement Type: Discrete/String
# Retention_7
#   Interpretation: Boolean measure to verify that the player retention was effective for 7 days at least
#   Data Type: Nominal
#   Measurement Type: Discrete/String


# # Strategy of Analysis

# In[10]:


# The most accurate way to test changes is to perform A/B testing by targeting a specific variable, in the case retention 
# (for 1 and 7 days after installation).
# We have two groups in the version variable:
#   Control Group: The time gate is located at level 30. We are going to consider this one as a no-treatment group.
#   Treatment Group: The company plans to move the time gate to level 40. We are going to use this as a subject of study,
# due to the change involved. 
# In an advanced stage, we are going to perform a bootstraping technique, to be confident about the result comparison for the
# retention probabilities between groups.


# In[11]:


# Counting the number of players in each AB group.
players_g30 = df[df['version'] == 'gate_30']
players_g40 = df[df['version'] == 'gate_40']

print('Number of Players tested at Gate 30:', str(players_g30.shape[0]), '\n',
     'Number of players tested at Gate 40:', str(players_g40.shape[0]))


# In[12]:


# As we see the proportion of players sampled for each group is balanced, so for now, only exploring the Game Rounds data is
# in the queue. Let's see the distribution of Game Rounds (The plotly layout created is available in Vizformatter library).


# In[13]:


import matplotlib.pyplot as plt
get_ipython().run_line_magic('matplotlib', 'inline')

import plotly.express as px


# In[14]:


box1 = px.box(df, x = "sum_gamerounds",
             title = "Game Rounds Overall Distribution by Player", labels = {"sum_gamerounds":"Game Rounds Registered"})

box1.show()


# In[15]:


# For now, we see that there exists clear outliers in the dataset since one user has recorded 49,854 Game rounds played in less
# than 14 days, meanwhile, the max recorded, excluding the outlier, is 2961. The only response to this case situation is a 
# "bot", a "bug", or a "glitch".
# Nevertheless, it's preferable to clean it, since only affected one record. Let's prune it.


# In[16]:


df = df[df['sum_gamerounds'] != 49854]


# In[17]:


# we can make an Empirical Cumulative Distribution Function, to see the real distribution of our data.
# Note: In this case, we won't use histograms to avoid a binning bias.


# In[18]:


import plotly.graph_objects as go

# Import numpy library.
import numpy as np

# ECDF Generator Function
def ecdf (data):
    # Generate ECDF (Empirical Cumulative Distribution Function)
    # for on dimension arrays
    n = len (data)
    
    # x-axis data
    x = np.sort(data)
    
    # y-axis data
    y = np.arange (1, n+1)/n
    
    return x, y

# Generate ECDF data
x_rounds, y_rounds = ecdf(df['sum_gamerounds'])

# Generate percentile makers
percentiles = np.array([5,25,50,75,95])
ptiles = np.percentile(df['sum_gamerounds'], percentiles)

# ECDF plot
ecdf = go.Figure()

# Add traces
ecdf.add_trace(go.Scatter(x=x_rounds, y=y_rounds,
                         mode = 'markers',
                         name = 'Game Rounds'))
ecdf.add_trace(go.Scatter(x=ptiles, y=percentiles/100,
                         mode='markers+text',
                         name='Percentiles', marker_line_width = 2, marker_size = 10,
                         text=percentiles, textposition="bottom right"))

ecdf.update_layout(title='Game Rounds Cumulative Distribution Plot', yaxis_title="Cumulative Probability")
ecdf.show()


# In[19]:


# As we see 95% of our data is below 500 game rounds.
print("The 95 percentile of the data is at: ", ptiles[4], "Game Rounds", "\n",
     "This means", df[df["sum_gamerounds"] <= ptiles[4]].shape[0], "players")


# In[20]:


# For us, this can be considered a valuable sample.
# In the plot above, we saw some players that installed the game but, then never return (0 game rounds).


# In[21]:


print("Players inactive since installation: ", df[df["sum_gamerounds"] == 0].shape[0])


# In[22]:


# And in most cases, players just play a couple of game rounds in their first two weeks. But, we are looking for players that
# like the game and to get hooked, that's one of our interests.
# A common matric in the video gaming industry for how fun and engaging a game is 1-day retention as mentioned before.


# # Player Retention Analysis

# In[23]:


# Retention is the percentage of players that come back and plays the game one day after they have installed it. The higher 
# 1-day retention is, the easier it is to retain players and build a large player base.
# According to Anders Drachen et al. (2013), these customer kind metrics "are notably interesting to professionals working with
# marketing and management of games and game development", also this metric is described simply as "how sticky the game is", in
# other words, it's essential.


# # 1-Day Retention by A/B Group

# In[24]:


# As a first step, lets look at how 1-day retention differs between the two AB groups. 
# Calculating 1-day retention for each AB-group

# Control Group
prop_gate30 = len(players_g30[players_g30['retention_1'] == True])/len(players_g30['retention_1'])*100

# Treatment Group
prop_gate40 = len(players_g40[players_g40['retention_1'] == True])/len(players_g40['retention_1'])*100

print('Group 30 at 1-day retention: ', str(round(prop_gate30,2)), "%", "\n",
     'Group 40 at 1-day retention: ', str(round(prop_gate40,2)), "%")


# In[25]:


# It appears that there was a slight decrease in 1-day retention when the gate was moved to level 40 (44.23%) compared to the 
# control when it was at level 30 (44.82%).
# It's a smallish change, but even small changes in retention can have a huge impact. While, we are sure of the difference in 
# data, how confident should we be that a gate at level 40 will be more threatening in the future?
# For this reason, it's important to consider bootstraping techniques, this means "a sampling with replacement from observed
# data to estimate the variability in a statistic of interest". In this case, retention, and we are going to do a function 
# for that.


# In[26]:


# Bootstraping Function
def draw_bs_reps(data, func, iterations = 1):
    boot_xd = []
    for i in range (iterations):
        boot_xd.append(func(data = np.random.choice(data, len(data))))
    return boot_xd
# Retention Function
def retention(data):
    ret = len(data[data == True])/len(data)
    return ret


# # Control Group Bootstraping

# In[27]:


# Bootstraping for Gate 30
btg30_1d = draw_bs_reps(players_g30['retention_1'], retention, iterations = 1000)


# # Treatment Group Bootstraping

# In[28]:


# Bootstraping for Gate 40
btg40_1d = draw_bs_reps(players_g40['retention_1'], retention, iterations = 1000)


# In[29]:


# Now let's check the results:
import plotly.figure_factory as ff

mean_g40 = np.mean(btg40_1d)
mean_g30 = np.mean(btg30_1d)

# A Kernel Density Estimate plot of the bootstrap distributions
boot_1d = pd.DataFrame(data = {'gate_30':btg30_1d, 'gate_40': btg40_1d},
                      index = range(1000))

# Plotting Histogram
hist_1d = [boot_1d.gate_30, boot_1d.gate_40]
dist_1d = ff.create_distplot(hist_1d, group_labels = ["Gate 30 (Control)", "Gate 40 (Treatment)"], show_rug = False, colors = ['#3498DB', '#28B463'])

# Add vertical lines for the mean retention rates
dist_1d.add_vline(x = mean_g40, line_dash = "dash", line_color = '#28B463')
dist_1d.add_vline(x = mean_g30, line_dash = "dash", line_color = '#3498DB')

# Add a rectangle to represent the difference in retention rates
dist_1d.add_shape(type = "rect", x0 = mean_g30, y0 = 0, x1 = mean_g40, y1 = 1, line = dict(color = "#F1C40F", width = 0), fillcolor = "#F1C40F", opacity = 0.2)

# Update the layout
dist_1d.update_layout(xaxis_range = [0.43, 0.46])
dist_1d.update_layout(title = '1-Day Retention Bootstrapping by A/B Group', xaxis_title = "Retention")
dist_1d.show()


# In[34]:


# The difference still looking close, is preferable to zoom it by plotting the difference as an individual measure.

# Adding a column with the % difference between the two AB-Groups.
boot_1d['diff'] = (
                    ((boot_1d['gate_30'] - boot_1d['gate_40']) / boot_1d['gate_40']) * 100
                )

# Plotting the bootstrap % difference
hist_1d_diff = [boot_1d['diff']]
dist_1d_diff = ff.create_distplot(hist_1d_diff, show_rug = False, colors = ['#F1C40F'],
                                 group_labels = ["Gate 30 - Gate 40"], show_hist = False)
dist_1d_diff.add_vline(x = np.mean(boot_1d['diff']), line_width = 3, line_dash = "dash", line_color = "black")
dist_1d_diff.update_layout(xaxis_range = [-3, 6])
dist_1d_diff.update_layout(title = 'Percentage of "1 day retention" difference between A/B Groups', xaxis_title = "% Difference")
dist_1d_diff.show()


# In[36]:


# From this chart, we can see that the percentual difference is around 1% - 2%, and that most of the distribution is above 0%, 
# in favour of a gate at level 30.
prob = (boot_1d['diff'] > 0.0).sum() / len(boot_1d['diff'])

# Printing the probability
print('The probability of Group 30 (Control) having a higher \n retention than Group 40 (Treatment) is: ', prob* 100, '%')


# # 7-Day Retention by A/B Group

# In[38]:


# The bootstrap analysis tells us that there is a high probability that 1-day retention is better when the time gate is at
# level 30. However, since players have only been playing the game for 1-day, likely, most players haven't reached level 30 yet.
# That is, many players won't have been affected by the gate, even if it's as early as level 30.
# But after having played for a week, more players should have reached level 40, and therefore it makes sense to also look at 
# 7-day retention. That is: What percentage of people that installed the game also showed up a week later to play the game again?
# Let's start by calculating 7-day retention for the two AB groups.


# In[39]:


# Calculating 7-day retention for both AB-groups
ret30_7d = len(players_g30[players_g30['retention_7'] == True])/len(players_g30['retention_7']) * 100
ret40_7d = len(players_g40[players_g40['retention_7'] == True])/len(players_g40['retention_7']) * 100

print('Group 30 at 7-day retention: ', str(round(ret30_7d, 2)), "%", "\n",
     'Group 40 at 7-day retention: ', str(round(ret40_7d,2)), "%")


# In[40]:


# Like with 1-day retention, we see that 7-day retention is barely lower (18.20%) when the gate is at level 40 than when the
# time gate is at level 30 (19.02%). This difference is also larger than for 1-day retention.
# We also see that the overall 7-day retention is lower than the overall 1-day retention; fewer people play a game a week than a
# day after installing.
# But as before, let's use bootstrap analysis to figure out how sure we can be of the difference between the AB-groups.


# # Control & Treatment Group Bootstrapping

# In[49]:


# Creating a list with bootstrapped means for each AB-group

# Bootstrapping for CONTROL group
btg30_7d = draw_bs_reps(players_g30['retention_7'], retention, iterations = 500)

# Bootstrapping for TREATMENT group
btg40_7d = draw_bs_reps(players_g40['retention_7'], retention, iterations = 500)

boot_7d = pd.DataFrame(data = {'gate_30':btg30_7d, 'gate_40':btg40_7d},
                      index = range(500))

# Adding a column with the % difference between the two AB-groups
boot_7d['diff'] = (boot_7d['gate_30'] - boot_7d['gate_40']) /  boot_7d['gate_30'] * 100


# Plotting the bootstrap % difference
hist_7d_diff = [boot_7d['diff']]
dist_7d_diff = ff.create_distplot(hist_7d_diff, show_rug = False, colors = ['#FF5733'],
                                 group_labels = ["Gate 30 - Gate 40"], show_hist = False)
dist_7d_diff.add_vline(x = np.mean(boot_7d['diff']), line_width = 3, line_dash = "dash", line_color = "black")
dist_7d_diff.update_layout(xaxis_range = [-4, 12])
dist_7d_diff.update_layout(title = 'Percentage of "7-day retention" difference between A/B groups', xaxis_title = "% Difference")
dist_7d_diff.show()



# Calculating the probability that 7-day retention is greater when the gate is at level 30
prob = (boot_7d['diff'] > 0).sum() / len(boot_7d)

# Printing the probability
print('The probability of Group 30 (Control) having a higher \n retention than Group 40 (Treatment) is:~', prob*100, '%')


# # Final Thoughts & Takeaways

# # What can the shareholders understand and take in consideration?

# In[50]:


# As discussed earlier, retention is crucial, because if we don't retain our player base, it doesn't matter how much money they
# spend in-game purchases.
# So, why is retention higher when the gate is positioned earlier? Normally, we could expect the opposite: The later the obstacle,
# the longer people get engaged with the game. But this is not what the data tells us, we explained this with the theory of 
# hedonic adaptation.


# # What could the stakeholders do to take action?

# In[51]:


# Now, we have enough statistical evidence to say that 7-day retention is higher when the gate is at level 30, than when it is 
# at level 40, the same as we concluded for 1-day retention. If we want to keep consumer retention high, we should not move the 
# gate from level 30 to level 40, it means we keep our Control method in the current gate system.


# # What can shareholders keep working on?

# In[ ]:


# For coming strategies the Game Designer can consider that, by pushing players to take a break when they reach a gate, the 
# fun of the game is postponed. But, when the gate is moved to level 40, they are more likely to quit the game beacuse they 
# simply got bored of it.

