
class WeightArrayMisMatch(Exception):
  '''
    Array and associated weight array do not have the same length.
  '''
  def __init__(self, message="Weight array and associated values array are not the same length."):
    self.message = message
    super().__init__(self.message) 
    
class NegativeWeightArrayValue(Exception):
  '''
    Weight array has at least one negative value..
  '''
  def __init__(self, message="Weight array has at least one negative value."):
    self.message = message
    super().__init__(self.message) 
    
class WeightSumNotPositive(Exception):
  '''
    Weight array sum is not positive.
  '''
  def __init__(self, message="Sum of weight array values is not positive."):
    self.message = message
    super().__init__(self.message) 
    
class NotNumpyArray(Exception):
  '''
    Array is not a numpy array.
  '''
  def __init__(self, message="Array is not a numpy array."):
    self.message = message
    super().__init__(self.message) 

class Not1DNumpyArray(Exception):
  '''
    Array is not a 1-D numpy array.
  '''
  def __init__(self, message="Array is not a 1-D numpy array."):
    self.message = message
    super().__init__(self.message) 

class Not2DNumpyMatrix(Exception):
  '''
    Array is not a matrix.
  '''
  def __init__(self, message="Array is not a numpy matrix."):
    self.message = message
    super().__init__(self.message) 
    
class NotProperQuantile(Exception):
  '''
    Array is not a numpy array.
  '''
  def __init__(self, message="Array as at least one value not in [0, 1]."):
    self.message = message
    super().__init__(self.message) 



