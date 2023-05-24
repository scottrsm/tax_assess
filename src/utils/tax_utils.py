import numpy as np
import array_except as ne


def wgt_quantiles(vs, wts, qs):
  '''
  Get a numpy array consisting of an array of quantile weighted <vs> values.
    
  Parameters
  ----------
  vs    A numpy(np) (N) array of numeric values. 
  wts   A numpy(np) (N) array of numeric weights. (Weights need only be non-negative, they need not sum to 1.)
  qs    A numpy(np) (D) array of numeric values.  (Meant to be quantiles -- numbers in the range [0, 1]).

  Returns
  -------
  :A numpy array consisting of the quantile weighted values of <vs> using weights, <wts>, for each quantile in <qs>.
  
  Return-Type
  -----------
  A numpy(np) (D) array of weighted quantile <vs> values with the same length as <qs>.
  
  Packages
  --------
  numpy(np)

Parameter Contract
  -----------------
    1. vs, wts, qs are all numpy arrays.
    2. qs in [0.0, 1.0]
    3. |vs| == |wts|
    4. all(wts) >= 0
    5. sum(wts) > 0
    
  Assumptions
  -----------
    1. <vs>, <wts>, and <qs> are all numeric arrays.
  '''
  
  ## 1. Are vs, wts, and qs are numpy arrays?
  if type(vs)  != np.ndarray:
    raise(ne.NotNumpyArray('wgt_quantiles: <vs> : Not a numpy array.'              ))
  if len(vs.shape) != 1:
    raise(ne.Not1DNumpyArray('wgt_quantiles_tensor: <vs>: Not a 1-D numpy array.'  ))
  if type(wts) != np.ndarray:
    raise(ne.NotNumpyArray('wgt_quantiles: <wts>: Not a numpy array.'              ))
  if len(wts.shape) != 1:
    raise(ne.Not1DNumpyArray('wgt_quantiles_tensor: <wts>: Not a 1-D numpy array.' ))
  if type(qs)  != np.ndarray:
    raise(ne.NotNumpyArray('wgt_quantiles: <qs> : Not a numpy array.'              ))
  if len(qs.shape) != 1:
    raise(ne.Not1DNumpyArray('wgt_quantiles_tensor: <qs>: Not a 1-D numpy array.'  ))
    
  ## 2. All qs values in [0.0, 1.0]?
  if any((qs < 0.0) | (qs > 1.0)):
    raise(ne.NotProperQuantile('wgt_quantiles: <qs>: Not a proper quantiles array.'))
  
  ## 3. The length of vs and wts is the same?
  if np.size(vs) != np.size(wts):
    raise(ne.WeightArrayMisMatch('wgt_quantiles: <vs> and <wts> do not have the same length.'))

  ## 4. all wts >= 0?
  if any(wts < 0.0):
    raise(ne.NegativeWeightArrayValue('wgt_quantiles: <wts> has one or more negative elements.'))

  ## 5. sum(wts) > 0?
  if sum(wts) <= 0:
    raise(ne.WeightSumNotPositive('wgt_quantiles: The sum of the elements of <wts> is not positive.'))
      
  ## Sort the vs array and the associated weights.
  ## Turn the weights into proper weights and create a cumulative weight array.
  idx  = np.argsort(vs)
  ovs  = vs[idx]
  ows  = wts[idx]
  ows  = ows / np.sum(ows) # Normalize the weights.
  cws  = np.cumsum(ows)
  
  N    = np.size(cws)
  M    = np.size(qs)
  
  ## Reshape to broadcast.
  cws.shape = (N, 1)
  qss = qs.copy()
  qss.shape  = (1, M)
  
  ## Use broadcasting to get all comparisons of <cws> with each entry from <qs>.  
  ## Form tensor (cws <= qss) * 1 and sandwich index of the value vectors with 0 and 1.
  A   = np.concatenate([np.ones(M).reshape(1,M), (cws <= qss) * 1, np.zeros(M).reshape(1,M)], axis=0)
  
  ## Get the diff -- -1 will indicate where the boundary is where cws > qs.
  X   = np.diff(A, axis=0).astype(int)
  
  ## Get the indices of the boundary.
  idx = np.maximum(0, np.where(X == -1)[0] - 1)
  
  ## Return the weighted quantile value of <vs> against each <qs>.
  return(ovs[idx])


def wgt_quantiles_tensor(vs, wts, qs):
  '''
  Return a numpy matrix consisting of weighted quantile values.
  For each row of <vs>, compute all of the weighted quantiles, <qs> using weight vector, <wts>.
    
  Parameters
  ----------
  vs    A numpy(np) (D, N) matrix of numeric values. 
  wgts  A numpy(np) (N) array of numeric weights. (Weights need only be non-negative, they need not sum to 1.)
  qs    A numpy(np) (M) array of numeric values.  (Meant to be quantiles -- numbers in the range [0, 1]).
  
  Returns
  -------
  A numpy array consisting of the quantile weighted values of <vs> using weights, <wts>, for each quantile in <qs>.
  
  Return-Type
  -----------
  A (D, M) numpy array of numeric values.
  
  Packages
  --------
  numpy(np)
  
  Parameter Contract
  -----------------
    1. vs, and wts are numpy arrays.
    2. vs is a numpy matrix.
    3. qs in [0.0, 1.0]
    4. |vs[0]| == |wts|
    5. all(wts) >= 0
    6. sum(wts) > 0
    
  Assumptions
  -----------
    1. <vs>, <wts>, and <qs> are all numeric arrays.

  '''
  
  ## 1. Are vs and wts are numpy arrays?
  if type(wts) != np.ndarray:
    raise(ne.NotNumpyArray(  'wgt_quantiles_tensor: <wts>: Not a numpy array.'  ))
  if len(wts.shape) != 1:
    raise(ne.Not1DNumpyArray('wgt_quantiles_tensor: <wts>: Not a 1-D array.'    ))
  if type(qs) != np.ndarray:
    raise(ne.NotNumpyArray(  'wgt_quantiles_tensor: <qs>: Not a numpy array.'   )) 
  if len(qs.shape) != 1:
    raise(ne.Not1DNumpyArray('wgt_quantiles_tensor: <qs>: Not a 1-D array.'     ))

  ## 2. Is vs is a numpy matrix?
  if type(vs)  != np.ndarray:
    raise(ne.NotNumpyArray(   'wgt_quantiles_tensor: <vs>: Not a numpy array.'  ))
  if len(vs.shape) != 2:
    raise(ne.Not2DNumpyMatrix('wgt_quantiles_tensor: <vs>: Not a numpy matrix.' ))

  ## 3. All qs values in [0.0, 1.0]?
  if any((qs < 0.0) | (qs > 1.0)):
    raise(ne.NotProperQuantile('wgt_quantiles_tensor: <qs>: Not a proper quantiles array.'))
  
  ## 4. The length of vs rows and the length of wts are the same?
  if np.size(vs[0]) != np.size(wts):
    raise(ne.WeightArrayMisMatch("wgt_quantiles_tensor: The rows of <vs> don't have the same length as <wts>."))

  ## 5. Are all wts elements >= 0?
  if any(wts < 0.0):
    raise(ne.NegativeWeightArrayValue('wgt_quantiles_tensor: Weights array, <wts>, has one or more negative elements.'))

  ## 6. Is sum(wts) > 0?
  if sum(wts) <= 0:
    raise(ne.WeightSumNotPositive('wgt_quantiles_tensor: The sum of the elements of <wts> is not positive.'))
  
  ## Normalize the weights.
  ws  = wts / np.sum(wts)
  
  D, N  = vs.shape
  M     = qs.size

  ## Get the sorted index array for each of the value vectors in vs.
  idx = np.argsort(vs, axis=1)
  
  ## Apply this index back to vs to get sorted values.
  ovs = np.take_along_axis(vs, idx, axis=1)
  
  ## Apply the index to the weights, where, the dimension of ws (and cws) expands to: (D, N).
  ows = ws[idx]
  cws = np.cumsum(ows, axis=1)

  ## Reshape to broadcast.
  cws.shape = (D, N, 1)
  qss = qs.copy()
  qss.shape  = (1, 1, M)

  ## Use broadcasting to get all comparisons of <cws> with each entry from <qs>. 
  ## Form tensor (cws <= qss) * 1 and sandwich index of the value vectors with 0 and 1.
  A = np.concatenate([np.ones(M*D).reshape(D,1,M), (cws <= qss) * 1, np.zeros(M*D).reshape(D,1,M)], axis=1)
  
  ## Compute the index difference on the value vectors.
  Delta = np.diff(A, axis=1).astype(int)

  ## Get the index of the values, this leaves, essentially, a (D, M) matrix. Reshape it as such.
  idx = np.maximum(0, np.where(Delta == -1)[1] - 1)
  idx = idx.reshape(D, M) 
  
  ## Return the values in the value vectors that correspond to these indices -- the M quantiles for each of the D value vectors.
  ## A (D, M) matrix.
  return(np.take_along_axis(ovs, idx, axis=1))


def assessment_agr_rets(df, ret_field, wgt_field, filt=True):
  '''
  Computes the weighted averge returns over the date range of the data frame, <df>.
    
  Parameters
  ----------
  df       : A Pandas DataFrame with required fields.
  ret_field: A field representing an numpy array of returns.
  wgt_field: A weight field, used to weight the returns in a given row.
       
  Returns
  -------
  A numpy array of aggregated returns.
  
  Return-Type
  -----------
  numpy(np) array(float)
  
  Packages
  --------
  numpy(np)
  pandas
  '''
  
  ## If the filter value is a scalar -- replicate it to the length of the dataframe, <df>.
  fl = filt
  if np.shape(filt) == ():
    fl = np.repeat(filt, df.shape[0])

  return(np.average(np.stack(df.loc[fl, ret_field]), weights=df.loc[fl, wgt_field], axis=0)).astype(float)



def assessment_wgt_quant_rets(df, ret_field, wgt_field, quants, filt=True):
  '''
  Computes weighted quantiles of returns over the date range of the data frame, <df>.
    
  Parameters
  ----------
  df        : Pandas dataframe of length N and contains the field names of the returns and the weights from the variables: ret_field and wgt_field.
  ret_field : Field of <df> that contains D returns for each row.
  wgt_field : Field of <df> containing the weights. (Weights must be non-negative, but do not need to sum to 1.
  quants    : A numpy (M) array of quantiles (in the range [0, 1]).

  Returns
  -------
  A numpy array of weighted quantile returns.
            :
  Return-Type
  -----------
  A (D, M) numpy array.
  
  Packages
  --------
  numpy(np)
  pandas

  Assumptions
  -----------
    1. The fields, <ret_field> and <wgt_field> hold numeric values in <df>.
    2. <quants> is a numeric vector. 
  '''
  
  ## If the filter value is a scalar -- replicate it to the length of the dataframe, <df>.
  fl = filt
  
  ## Apply the filter to the data set.
  if np.shape(filt) == ():
    fl = np.repeat(filt, df.shape[0])

  ## Make a copy of the data set and retrieve the weights (N) and the (D, N) array of returns.
  A = df.loc[fl, :].copy()  
  W = A[wgt_field].to_numpy()
  A = np.dstack(A[ret_field])[0]

  ## Compute the DxM quantile returns.
  return(wgt_quantiles_tensor(A, W, quants))




def assessment_wgt_median_rets(df, ret_field, wgt_field, filt=True):
  '''
  Computes weighted median over the return arrays in the field <ret_field> using the weights in field, <wgt_field>.

  Parameters
  ----------
  df        : Pandas dataframe of length N and contains the field names of the returns and the weights from the variables: ret_field and wgt_field.
  ret_field : Field of <df> that contains D returns for each row.
  wgt_field : Field of <df> containing the weights. (Weights must be non-negative, but do not need to sum to 1.)

  Returns
  -------
  A numpy array of weighted quantile returns.

  Return-Type
  -----------
  A (D) numpy array.

  Packages
  --------
  numpy(np)
  pandas

  Assumptions
  -----------
    1. The fields, <ret_field> and <wgt_field> hold numeric values in <df>.
  '''

  ## If the filter value is a scalar -- replicate it to the length of the dataframe, <df>.
  fl = filt

  ## Apply filter.
  if np.shape(filt) == ():
    fl = np.repeat(filt, df.shape[0])

  A = df.loc[fl, :].copy()
  W = A[wgt_field].to_numpy()
  A = np.dstack(A[ret_field])[0]

  Z = wgt_quantiles_tensor(A, W, np.array([0.5]))
  return(Z[:, 0])

