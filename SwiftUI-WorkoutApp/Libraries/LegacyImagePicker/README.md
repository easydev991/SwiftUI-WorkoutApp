# LegacyImagePicker

Содержит `PHPickerViewController`, обернутый в `UIViewControllerRepresentable`, для использования в `SwiftUI` для выбора изображений из `PhotoLibrary`.

`PHPickerViewController` имеет ошибку: он позволяет выбирать несколько элементов, нажимая несколько раз очень быстро (даже один и тот же элемент) перед исчезновением пикера, ​​даже если для параметра `selectionLimit` установлено значение `1`.

Используется только в версиях iOS ниже 16.
