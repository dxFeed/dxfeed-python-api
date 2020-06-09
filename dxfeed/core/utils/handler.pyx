from warnings import warn
from collections import deque
import pandas as pd


cdef class EventHandler:
    # TODO: docs
    def __init__(self):
        self.columns = list()

    cdef void __update(self, event) nogil:
        with gil:
            self.update(event)

    def update(self, event):
        warn(Warning('You have not implemented update method in your EventHandler, that is called, when event comes!'))

cdef class DefaultHandler(EventHandler):
    # TODO: docs
    def __init__(self, data_len: int=100000):
        self.__data = deque(maxlen=data_len)

    def update(self, event):
        self.__data.append(event)

    def get_list(self):
        data = self.__data.copy()
        self.__data.clear()
        return list(data)

    def get_dataframe(self, keep: bool=True):
        df_data = self.__data.copy()
        if not keep:
            self.__data.clear()

        df = pd.DataFrame(df_data, columns=self.columns)
        time_columns = df.columns[df.columns.str.contains('Time')]
        for column in time_columns:
            df.loc[:, column] = df.loc[:, column].astype('<M8[ms]')
        return df
