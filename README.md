**Runtime versus compile-time known length in slices**

The basic idea is that a thing is compile-time known, when we know everything (the value, the attributes and the characteristics) about this thing at compile-time.

- When the range of indexes is known at compile-time, the slice that gets created is just a pointer to an array, accompanied by a length value that tells the size of the slice.
- On the other hand, if the range of indexes is not known at compile-time, the, the slice object that gets created is not a pointer anymore, and, thus, it does not support pointer operator. \
  For example, maybe the start index is known at compile time, but the end index is not. In such case, the range of the slice becomes runtime known only.
