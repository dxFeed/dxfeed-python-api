# from multiprocessing import Lock
from collections import deque
from threading import Lock

class DequeWithLock(deque):
    def __init__(self, iterable=(), maxlen=None):
        super().__init__(iterable, maxlen)
        self.lock = Lock()

    def safe_append(self, data):
        try:
            self.lock.acquire()
            self.append(data)
        finally:
            self.lock.release()

    def safe_get(self):
        list_to_return = list()
        try:
            self.lock.acquire()
            list_to_return = self.copy()
            self.clear()
        finally:
            self.lock.release()
        return list(list_to_return)

    def safe_copy(self):
        list_to_return = list()
        try:
            self.lock.acquire()
            list_to_return = self.copy()
        finally:
            self.lock.release()
        return list(list_to_return)