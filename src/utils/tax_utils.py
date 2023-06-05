import numpy as np
import vec_analytics as va



def assessment_agr_rets(df, ret_field, wgt_field, filt=True):
    '''
    Computes the weighted average returns over the date range of the data frame, <df>.
    
    Parameters
    ----------
    df       : A Pandas DataFrame with required fields.
    ret_field: A field representing an numpy array of returns.
    wgt_field: A weight field, used to weight the returns in a given row.
       
    Returns
    -------
    A numpy array of aggregated returns.
  
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
    df        : Pandas DataFrame of length N and contains the field names of the returns and the weights from the variables: ret_field and wgt_field.
    ret_field : Field of <df> that contains D returns for each row.
    wgt_field : Field of <df> containing the weights. (Weights must be non-negative, but do not need to sum to 1.)
    quants    : A numpy (M) array of quantiles (in the range [0, 1]).

    Returns
    -------
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
  
    ## If the filter value is a scalar -- replicate it to the length of the DataFrame, <df>.
    fl = filt
  
    ## Apply the filter to the data set.
    if np.shape(filt) == ():
        fl = np.repeat(filt, df.shape[0])

    ## Make a copy of the data set and retrieve the weights (N) and the (D, N) array of returns.
    A = df.loc[fl, :].copy()  
    W = A[wgt_field].to_numpy()
    A = np.dstack(A[ret_field])[0]

    ## Compute the DxM quantile returns.
    return(va.wgt_quantiles_tensor(A, W, quants))




def assessment_wgt_median_rets(df, ret_field, wgt_field, filt=True):
    '''
    Computes weighted median over the return arrays in the field <ret_field> using the weights in field, <wgt_field>.

    Parameters
    ----------
    df        : Pandas DataFrame of length N and contains the field names of the returns and the weights from the variables: ret_field and wgt_field.
    ret_field : Field of <df> that contains D returns for each row.
    wgt_field : Field of <df> containing the weights. (Weights must be non-negative, but do not need to sum to 1.)

    Returns
    -------
    A (D) numpy array.

    Packages
    --------
    numpy(np)
    pandas

    Assumptions
    -----------
    1. The fields, <ret_field> and <wgt_field> hold numeric values in <df>.
    '''

    ## If the filter value is a scalar -- replicate it to the length of the DataFrame, <df>.
    fl = filt

    ## Apply filter.
    if np.shape(filt) == ():
        fl = np.repeat(filt, df.shape[0])

    A = df.loc[fl, :].copy()
    W = A[wgt_field].to_numpy()
    A = np.dstack(A[ret_field])[0]

    Z = va.wgt_quantiles_tensor(A, W, np.array([0.5]))
    return(Z[:, 0])

