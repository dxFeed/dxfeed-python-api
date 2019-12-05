from multiprocessing import Lock
# from collections import deque
from threading import Lock
from collections import deque
import sys
import time

class DequeWithLock(deque):
    def __init__(self, iterable=(), maxlen=None):
        super().__init__(iterable, maxlen)
        self.lock = Lock()

    def safe_append(self, data):
        print('Try to append', file=sys.stderr)
        try:
            print('In try block', file=sys.stderr)
            self.lock.acquire()
            self.append(data)
            print('Appended', file=sys.stderr)
        finally:
            print('Try to release', file=sys.stderr)
            self.lock.release()
            print('released', file=sys.stderr)

    # def get_all(self):
    #     list_to_return = list()
    #     try:
    #         self.lock.acquire()
    #         while len(self):
    #             list_to_return.append(self.get())
    #     finally:
    #         self.lock.release()
    #     return list_to_return

    def get_all_test(self, sleep=1):

        list_to_return = list()
        try:
            self.lock.acquire()
            print('after aquire', len(self))
            time.sleep(sleep)
            print('after aquire and sleep', len(self))
            list_to_return = self.copy()
            self.clear()
        finally:
            self.lock.release()
        print('after release', len(self))
        time.sleep(sleep)
        print('after release and sleep', len(self))
        return list_to_return