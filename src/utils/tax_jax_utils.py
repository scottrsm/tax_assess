import numpy as np
import jax.numpy as jnp
import jax_vec_analytics as jva



def assessment_agr_rets(df, ret_field, wgt_field, filt=True):
  '''
  Computes the weighted averge returns over the date range of the data frame, <df>.
    
  Parameters
  ----------
  df       : A Pandas DataFrame with required fields.
  ret_field: A field representing an (M) numpy array of returns.
  wgt_field: A weight field, used to weight the returns in a given row.
       
  Returns
  -------
  A numpy array of aggregated returns.
  
  Return-Type
  -----------
  numpy(np) array (M) (float)
  
  Packages
  --------
  numpy(np)
  jax.numpy(jnp)
  pandas
  '''
  
  ## If the filter value is a scalar -- replicate it to the length of the dataframe, <df>.
  fl = filt
  if np.shape(filt) == ():
    fl = np.repeat(filt, df.shape[0])

  A = np.stack(df.loc[fl, ret_field]).astype(float)
  A = jnp.asarray(A)
  W = jnp.asarray(df.loc[fl, wgt_field])
  return(jnp.average(jnp.stack(A), weights=W, axis=0)).astype(float)



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
 
  ## Get the numpy (D, N) Matrix of returns from the dataframe and the corresponding numpy (N) array of weights.
  A = np.dstack(df.loc[fl, ret_field])[0].astype(float)
  W = df.loc[fl, wgt_field].to_numpy()

  ## Compute the DxM numpy quantile returns.
  return(jva.wgt_quantiles_tensor(A, W, quants))


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
  A numpy (M) array of weighted quantile returns.

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

  A = np.dstack(df.loc[fl, ret_field])[0].astype(float)
  W = A[wgt_field].to_numpy()

  Z = jva.wgt_quantiles_tensor(A, W, np.array([0.5]))
  return(Z[:, 0])



