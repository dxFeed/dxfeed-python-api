# from multiprocessing import Lock
from collections import deque
from typing import Any
from threading import Lock


class DequeWithLock(deque):
    """
    Class that provides lock mechanism to deque from collections for append, copy and get operations
    """
    def __init__(self, iterable=(), maxlen=None):
        super().__init__(iterable, maxlen)
        self.lock = Lock()

    def safe_append(self, data: Any):
        """
        Method appends data while locked

        Parameters
        ----------
        data: any
            Data to append
        """
        try:
            self.lock.acquire()
            self.append(data)
        finally:
            self.lock.release()

    def safe_get(self):
        """
        Method that pops all the data with subsequent clearing

        Returns
        -------
        list_to_return: list
            List filled with data
        """
        list_to_return = list()
        try:
            self.lock.acquire()
            list_to_return = self.copy()
            self.clear()
        finally:
            self.lock.release()
        return list(list_to_return)

