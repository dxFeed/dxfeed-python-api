from warnings import warn
from collections import deque
import pandas as pd


cdef class EventHandler:
    """
    Master class for user defined event handlers. `update` method should be considered as abstract.

    Attributes
    ----------
    columns: list
        After attaching listener the field contains one-word descriptors of the values in upcoming event the order
        coincides
    """
    def __init__(self):
        self.columns = list()

    cdef void __update(self, event) nogil:
        with gil:
            self.update(event)

    def update(self, event: list):
        """
        Method that is called, when event arrives to related Subscription. Currently (Cython version 0.29.17),
        abstract methods are not implemented, so this implementation is sort of stub method.

        Parameters
        ----------
        event: list
            List of various data specific to certain event type
        """
        warn(Warning('You have not implemented update method in your EventHandler, that is called, when event comes!'))

cdef class DefaultHandler(EventHandler):
    """
    The class implements one possible event handler, which is considered as default. This class just stores upcoming
    events in deque and has methods to get data as list or as pandas.DataFrame.

    Attributes
    ----------
    data_len: int
        The length of internal collections.deque object. Default is 100000.
    columns: list
        After attaching listener the field contains one-word descriptors of the values in upcoming event the order
        coincides.
    """
    def __init__(self, data_len: int=100000):
        self.__data = deque(maxlen=data_len)

    def update(self, event: list):
        """
        Utility method that is called by underlying Cython level when new event is received. Sores events in
        collection.deque.

        Parameters
        ----------
        event: list
            List of various data specific to certain event type.
        """
        self.__data.append(event)

    def get_list(self):
        """
        Method to get data stored in collections.deque as list.

        Returns
        -------
        data: list
            List of received events.
        """
        data = self.__data.copy()
        self.__data.clear()
        return list(data)

    def get_dataframe(self, keep: bool=True):
        """
        Returns received data as pandas.DataFrame object.

        Warning
        -------
        There are no restriction on attaching one event handler to several subscriptions. In this case, method will
        work correctly if different subscriptions have same event type. Otherwise error will occur.

        Parameters
        ----------
        keep: bool
            When False clears internal collections.deque object after call. Default True.

        Returns
        -------
        df: pandas.DataFrame
            Dataframe with received events.
        """
        df_data = self.__data.copy()
        if not keep:
            self.__data.clear()

        df = pd.DataFrame(df_data, columns=self.columns)
        time_columns = df.columns[df.columns.str.contains('Time')]
        for column in time_columns:
            df.loc[:, column] = df.loc[:, column].astype('<M8[ms]')
        return df
