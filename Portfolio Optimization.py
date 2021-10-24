#!/usr/bin/env python
# coding: utf-8

# In[1]:


# Optimize a users portfolio using Efficient Frontier (maximize exp. return and minimize risk)


# In[3]:


# Import libraries
from pandas_datareader import data as web
import pandas as pd 
import numpy as np
from datetime import datetime
import matplotlib.pyplot as plt
plt.style.use('fivethirtyeight')


# In[4]:


# Get tickers in portfolio
# FAANG tickers

assets = ['FB', 'AMZN', 'AAPL', 'NFLX', 'GOOG']


# In[5]:


# Assign weights to stocks (sum = 1)

weights = np.array([0.2, 0.2, 0.2, 0.2, 0.2])


# In[6]:


# Get start date

stockStartDate = '2013-01-01'


# In[7]:


# Get end date

today = datetime.today().strftime('%Y-%m-%d')
today


# In[10]:


# Create a dataframe to store the adjusted close price of the stocks

df = pd.DataFrame()

# Store the adjusted close price of the stock into the df

for stock in assets:
    df[stock] = web.DataReader(stock, data_source='yahoo', start = stockStartDate, end = today)['Adj Close']


# In[11]:


# Show the df 

df


# In[14]:


# Visually show the portfolio

title = 'Portfolio Adj. Close Price History'

# Get the stocks

my_stocks = df

# Create and plot the graph

for c in my_stocks.columns.values:
    plt.plot(my_stocks[c], label = c)
    
plt.title(title)
plt.xlabel('Date', fontsize = 18)
plt.ylabel('Adj. Price USD ($)', fontsize = 18)
plt.legend(my_stocks.columns.values, loc= 'upper left')
plt.show()


# In[15]:


# Show daily simple return

returns = df.pct_change()
returns


# In[16]:


# Create and show the annualized covariance matrix

cov_matrix_annual = returns.cov() * 252
cov_matrix_annual


# In[17]:


# Calculate the portfolio variance

port_variance = np.dot(weights.T, np.dot(cov_matrix_annual, weights))
port_variance


# In[18]:


# Calculate the portfolio volatility aka standard deviation
port_volatility = np.sqrt(port_variance)
port_volatility


# In[19]:


# Calculate annual portfolio return 

portfolioSimpleAnnualReturn = np.sum(returns.mean() * weights) * 252
portfolioSimpleAnnualReturn


# In[26]:


# Show the expected annual return, volatiltiy (risk), and variance

percent_var = str( round(port_variance, 2) * 100) + '%'
percent_vol = str( round(port_volatility, 2) * 100) + '%'
percent_ret = str( round(portfolioSimpleAnnualReturn, 2) * 100) + '%'

print('Expected annual return: '+ percent_ret)
print('Annual volatility / risk: '+ percent_vol)
print('Annual variance: '+ percent_var)


# In[27]:


from pypfopt.efficient_frontier import EfficientFrontier
from pypfopt import risk_models
from pypfopt import expected_returns


# In[28]:


# Portfolio Optimization 

# Calculate the expected returns and the annualized sample covariance matrix of asset returns

mu = expected_returns.mean_historical_return(df)
S = risk_models.sample_cov(df)

# Optimize for maximum sharpe ratio

ef = EfficientFrontier(mu, S)
weights = ef.max_sharpe()
cleaned_weights = ef.clean_weights()
print(cleaned_weights)
ef.portfolio_performance(verbose = True)


# In[29]:


0.14943 + 0.29205 + 0.24857 + 0.29168 + 0.01828


# In[ ]:





# In[ ]:




