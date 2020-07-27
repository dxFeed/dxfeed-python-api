from warnings import warn
from dxfeed.core.utils.data_class import DequeWithLock as deque_wl
import pandas as pd
from typing import Iterable


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

    cdef void cython_internal_update_method(self, event) nogil:
        with gil:
            self.update(event)

    def update(self, event: Iterable):
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
    def __init__(self, data_len: int=100000):
        """
        The class implements one possible event handler, which is considered as default. This class just stores upcoming
        events in custom deque with thread lock and has methods to get data as list or as pandas.DataFrame.

        Attributes
        ----------
        data_len: int
            The length of internal DequeWithLock object. Default is 100000.
        columns: list
            After attaching listener the field contains one-word descriptors of the values in upcoming event the order
            coincides.
        """
        super().__init__()
        self.__data = deque_wl(maxlen=data_len)

    def update(self, event: Iterable):
        """
        Utility method that is called by underlying Cython level when new event is received. Stores events in
        DequeWithLock.

        Parameters
        ----------
        event: list
            List of various data specific to certain event type.
        """
        self.__data.safe_append(event)

    def get_list(self, keep: bool=True):
        """
        Method to get data stored in DequeWithLock as list.

        Parameters
        ----------
        keep: bool
            When False clears internal DequeWithLock object after call. Default True.

        Returns
        -------
        data: list
            List of received events.
        """
        data = self.__data.safe_get(keep=keep)
        return data

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
            When False clears internal DequeWithLock object after call. Default True.

        Returns
        -------
        df: pandas.DataFrame
            Dataframe with received events.
        """
        df_data = self.get_list(keep=keep)


        df = pd.DataFrame(df_data, columns=self.columns)
        time_columns = df.columns[df.columns.str.contains('Time')]
        for column in time_columns:
            df.loc[:, column] = df.loc[:, column].astype('<M8[ms]')
        return df
