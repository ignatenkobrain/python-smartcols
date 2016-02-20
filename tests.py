import unittest
import smartcols

class Column(unittest.TestCase):
    def setUp(self):
        self.column = smartcols.Column()
    def test_flags(self):
        for flag in ["trunc", "tree", "right", "strict_width",
                     "noextremes", "hidden", "wrap"]:
            setattr(self.column, flag, True)
            self.assertTrue(getattr(self.column, flag))
            setattr(self.column, flag, False)
            self.assertFalse(getattr(self.column, flag))
    def test_name(self):
        self.assertIsNone(self.column.name)
        self.column.name = "FOO"
        self.assertEqual(self.column.name, "FOO")
        self.column.name = None
        self.assertIsNone(self.column.name)
    def test_color(self):
        self.assertIsNone(self.column.color)
        self.column.color = "red"
        self.assertEqual(self.column.color, "\x1b[31m")
        self.column.color = None
        self.assertIsNone(self.column.color)
        self.column.color = "nonexistent"
        self.assertIsNone(self.column.color)

class Table(unittest.TestCase):
    def test_title(self):
        table = smartcols.Table()
        title = table.title
        self.assertEqual(title.position, "left")
        title.position = "left"
        self.assertEqual(title.position, "left")
        title.position = "center"
        self.assertEqual(title.position, "center")
        title.position = "right"
        self.assertEqual(title.position, "right")
        with self.assertRaises(KeyError):
            title.position = "nonexistent"

if __name__ == "__main__":
    unittest.main(verbosity=2)
